# End Date Propagator
#
# When editing the `end_date` of a record, the record's children often also
#   need to be updated. This propagator takes care of that.
# For each of the  child records (defined below in the function `children`),
#   the child record's `end_date` is updated to match that of the original
#   object. The main function `call` is recursive, propagating to children of
#   children and so on.
# Records that should not have their end dates propagated in this manner
#   (e.g. StatusRecords) are manually excluded in `non_ended_classes`.
# If there is some error preventing propagation, the child record is NOT saved,
#   and that error message is added to the object's `errors`. These errors
#   propagate upwards into a flattened array of error messages.
#
# Currently only propagates "default" span. The approach to implementing such
#   a feature is ambiguous - would all children have the same span propagated?
#   Would each acts_as_span model need a method to tell which span to
#   propagate to? Once there is a solid use case for using this object on
#   models with multiple spans, that will inform the implementation strategy.
module ActsAsSpan
  class EndDatePropagator
    attr_reader :object,
      :errors_cache,
      :skipped_classes

    def initialize(object, skipped_classes = [])
      @object = object
      @errors_cache = []
      @skipped_classes = skipped_classes
    end

    def call
      # no propagation if no span to propagate to
      return object unless object.respond_to?(:span)
      # no propagation if trying to propagate nil
      unless end_date_changed?(object) && !object.span.end_date.nil?
        return object
      end

      children(object).each do |child|
        # skip child if child end_date is greater than parent end_date
        next unless child.span.end_date.nil? ||
          child.span.end_date > object.span.end_date

        child.assign_attributes(
          { child.span.end_field => object.span.end_date }
        )

        # End the record, its children too. And their children, forever, true.
        child_obj = ActsAsSpan::EndDatePropagator.new(
          child, @skipped_classes
        ).call

        # append any errors that bubbled up from children
        if child_obj.errors[:base].flatten.present?
          errors_cache << child_obj.errors[:base]
        end

        next if child.save

        if child.errors.keys.include? child.span.end_field
          errors_cache << I18n.t(
            'propagation_failure',
            scope: [:activerecord, :errors, :messages, :end_date_propagator],
            end_date_field_name: child.class.human_attribute_name(
              child.span.end_field
            ),
            parent: object.model_name.human,
            child: child.model_name.human,
            reason: child.errors[child.span.end_field].join('; ')
          )
        end
      end

      # add just the strings, prevent ugly nested arrays in the view
      object.errors[:base].push(*errors_cache.flatten)

      # return the object, with any newly-added errors
      object
    end

    private

    # check if the end_date analog has changed
    def end_date_changed?(object)
      end_date_field = object.span.end_field.to_s
      object.changed.include? end_date_field
    end

    # Use acts_as_span to determine whether a record has an end date
    def should_propagate_to?(klass)
      klass.respond_to?(:span) &&
        @skipped_classes.exclude?(klass)
    end

    def child_associations(object)
      object.class.reflect_on_all_associations(:has_many).select do |reflection|
        %i[delete destroy].include?(reflection.options[:dependent]) &&
          should_propagate_to?(reflection.klass)
      end
    end

    def children(object)
      child_associations(object).flat_map do |reflection|
        object.send(reflection.name)
      end
    end

    attr_writer :object, :errors_cache
  end
end
