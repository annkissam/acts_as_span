# frozen_string_Literal: true

module ActsAsSpan
  # # End Date Propagator
  #
  # When editing the `end_date` of a record, the record's children often also
  #   need to be updated. This propagator takes care of that.
  # For each of the  child records (defined below in the function `children`),
  #   the child record's `end_date` is updated to match that of the original
  #   object. The function `propagate` is recursive, propagating to
  #   children of children and so on.
  # Records that should not have their end dates propagated in this manner
  #   (e.g. StatusRecords) are manually excluded in `skipped_classes`.
  # If there is some error preventing propagation, the child record is NOT saved
  #   and that error message is added to the object's `errors`. These errors
  #   propagate upwards into a flattened array of error messages.
  #
  # This class uses its own definition of 'child' for an object. For a given
  #   object, the objects the propagator considers its children are:
  #   * Associated via `has_many` association
  #   * Association `:dependent` option is `:delete` or `:destroy`
  #   * acts_as_span (checked via `respond_to?(:span)`)
  #   * Not blacklisted via `skipped_classes` array
  #
  # The return value for `call` is the given object, updated to have children's
  #   errors added to its `:base` errors if any children had errors.
  #
  # ## Usage:
  #
  # Propagate end dates for an object that acts_as_span and has propagatable
  # children to all propagatable children:
  # ```
  # ActsAsSpan::EndDatePropagator.call(object)
  # ```
  #
  # To propagate to a subset of its propagatable children:
  # ```
  # ActsAsSpan::EndDatePropagator.call(
  #   object, skipped_classes: [ClassOne, ClassTwo]
  # )
  # ```
  # ... where ClassOne and ClassTwo are the classes to be excluded.
  #
  # The EndDatePropagator does not use transactions. If the propagation should
  # be run in a transaction, wrap the call in one like so:
  # ```
  # ActiveRecord::Base.transaction do
  #   ActsAsSpan::EndDatePropagator.call(
  #     obj, skipped_classes: [ClassOne, ClassTwo]
  #   )
  # end
  # ```
  #
  # One use case for the transaction wrapper would be to not follow through
  # with propagation if the object has errors:
  # ```
  # ActiveRecord::Base.transaction do
  #   result = ActsAsSpan::EndDatePropagator.call(obj)
  #   if result.errors.present?
  #     fail OhNoMyObjetHasErrorsError, "Oh, no! My object has errors!"
  #   end
  # end
  # ```
  #
  # Currently only propagates "default" span. The approach to implementing such
  #   a feature is ambiguous - would all children have the same span propagated?
  #   Would each acts_as_span model need a method to tell which span to
  #   propagate to? Once there is a solid use case for using this object on
  #   models with multiple spans, that will inform the implementation strategy.
  class EndDatePropagator
    attr_reader :object,
                :errors_cache,
                :skipped_classes,
                :include_errors

    def initialize(object, errors_cache: [], skipped_classes: [], include_errors: true)
      @object = object
      @errors_cache = errors_cache
      @skipped_classes = skipped_classes
      @include_errors = include_errors
    end

    # class-level call: enable the usage of ActsAsSpan::EndDatePropagator.call
    def self.call(object, **opts)
      new(object, opts).call
    end

    def call
      result = propagate
      # only add new errors to the object
      result.errors.each do |error|
        if object.errors[error.attribute].exclude? error.message
          object.errors.add(error.attribute, error.message)
        end
      end
      object
    end

    private

    def propagate
      # return if there is nothing to propagate
      return object unless should_propagate_from? object

      children(object).each do |child|
        # End the record, its children too. And their children, forever, true.
        propagated_child = assign_end_date(child, object.span.end_date)

        # save child and add errors to cache
        save_with_errors(object, child, propagated_child)
      end

      if errors_cache.present?
        errors_cache.each do |message|
          next if object.errors.added?(:base, message)

          object.errors.add(:base, message)
        end
      end

      # return the object, with any newly-added errors
      object
    end

    # returns the given child, but possibly with errors
    def assign_end_date(child, new_end_date)
      child.assign_attributes({ child.span.end_field => new_end_date })
      ActsAsSpan::EndDatePropagator.call(
        child,
        errors_cache: errors_cache,
        skipped_classes: skipped_classes,
      )
    end

    # save the child record, add errors.
    def save_with_errors(object, child, propagated_child)
      if object_has_errors?(propagated_child) && include_errors
        errors_cache << propagation_error_message(object, child)
      end
      child.save
    end

    def propagation_error_message(object, child)
      I18n.t(
        'propagation_failure',
        scope: %i[activerecord errors messages end_date_propagator],
        end_date_field_name: child.class.human_attribute_name(
          child.span.end_field,
        ),
        parent: object.model_name.human,
        child: child.model_name.human,
        reason: child.errors.full_messages.join('; '),
      )
    end

    def object_has_errors?(object)
      !object.valid? ||
        (object.errors.present? && object.errors.messages.values.flatten.any?)
    end

    # check if the end_date analog is dirtied
    def end_date_changed?(object)
      end_date_field = object.span.end_field.to_s
      object.changed.include? end_date_field
    end

    def should_propagate_from?(object)
      object.respond_to?(:span) &&
        end_date_changed?(object) &&
        !object.span.end_date.nil?
    end

    # Use acts_as_span to determine whether a record has an end date
    def should_propagate_to?(klass)
      klass.respond_to?(:span) && @skipped_classes.exclude?(klass)
    end

    def child_associations(object)
      object.class.reflect_on_all_associations(:has_many).select do |reflection|
        %i[delete destroy].include?(reflection.options[:dependent]) &&
          should_propagate_to?(reflection.klass)
      end
    end

    def children(object)
      child_objects = child_associations(object).flat_map do |reflection|
        object.send(reflection.name)
      end

      # skip previously-ended children
      child_objects.reject do |child|
        child.span.end_date && child.span.end_date < object.span.end_date
      end
    end

    attr_writer :object, :errors_cache
  end
end
