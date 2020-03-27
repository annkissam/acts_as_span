# End Date Propagator
#
# When editing the `end_date` of a record, the record's children often also
#   need to be updated. This propagator takes care of that.
# For each of the  child records (defined below in the function `children`),
#   the child record's `end_date` is updated to match that of the original
#   object. The function `call_sans_transaction` is recursive, propagating to
#   children of children and so on.
# Records that should not have their end dates propagated in this manner
#   (e.g. StatusRecords) are manually excluded in `non_ended_classes`.
# If there is some error preventing propagation, the child record is NOT saved,
#   and that error message is added to the object's `errors`. These errors
#   propagate upwards into a flattened array of error messages.
#
# Summary of options that "call" will accept:
#   * transaction: (true or false)
#     Default is `true`.
#     When `true`, wraps the entire propagation in a single transaction,
#     rolling back all database changes if any propagation step raises an error.
#     When `false`, there are no transactions added by the EndDatePropagator.
#     Any errors will stop the propagator in its tracks, and everything that
#     will have been propagated will remain committed to the database.
#   * save: (true or false)
#     Default is `false`.
#     When `true`, the EndDatePropagator will attempt to call `save` on the
#     returned result.
#   * save!: (true or false)
#     This has the same behavior as the `:save` option, but calls `save!`
#     instead.
#     The `:save` and `:save!` options are mutually exclusive; the
#     EndDatePropagator will raise an error if both are entered.
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

    # Main interface function. See class documentation for details.
    def call(options = {})
      if options.values_at(:save, :save!).all? { |v| !!v }
        fail ArgumentError, "Options must include exactly one of :save or " +
          ":save!, but both were present."
      end

      # default: run with transaction
      if options.fetch(:transaction, true)
        result = call_with_transaction
      else
        result = call_sans_transaction
      end

      # save @object if asked to (only one option can get this far)
      if result && options.fetch(:save, false)
        object.errors.merge! result.errors
        object.save
        result = object
      end
      if result && options.fetch(:save!, false)
        object.errors.merge! result.errors
        result = object.save!
      end

      # prevent repeated calls from simply concatenating errors
      @errors_cache = []

      result
    end

    def call_with_transaction
      propagated_object = nil
      ActiveRecord::Base.transaction do
        propagated_object = call_sans_transaction
        if object_has_errors?(propagated_object)
          raise ActiveRecord::Rollback,
            I18n.t('rollback',
                   scope: %i[acts_as_span end_date_propagator])
        end
      end
      propagated_object
    end

    def call_sans_transaction
      # no propagation if no span to propagate to
      return object unless object.respond_to?(:span)
      # no propagation if trying to propagate nil;
      # reopening records' end dates could be a future feature
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
        propagated_child = ActsAsSpan::EndDatePropagator.new(
          child, skipped_classes
        ).call

        if object_has_errors?(propagated_child) || !propagated_child.valid?
          errors_cache << I18n.t(
            'propagation_failure',
            scope: %i[activerecord errors messages end_date_propagator],
            end_date_field_name: child.class.human_attribute_name(
              child.span.end_field
            ),
            parent: object.model_name.human,
            child: child.model_name.human,
            reason: child.errors.full_messages.join('; ')
          )
        end

        child.save
      end

      # add just the strings, prevent ugly nested arrays in the view
      object.errors[:base].push(*errors_cache.flatten)

      # reset errors cache to prevent duplicate errors on subsequent calls
      errors_cache = []

      # return the object, with any newly-added errors
      object
    end

    private

    def object_has_errors?(object)
      object.errors && object.errors.messages.values.flatten.any?
    end

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
