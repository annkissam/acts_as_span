require 'active_model'

module ActsAsSpan
  class NoOverlapValidator < ActiveModel::Validator
    def validate(record)
      overlapping_records = temporally_overlapping_for(record)
      instance_scope = options[:instance_scope].is_a?(Proc) ? record.instance_eval(&options[:instance_scope]) : true

      if overlapping_records.any? && instance_scope

        error_type = overlapping_records.size == 1 ? "no_overlap.one" : "no_overlap.other"

        record.errors.add(
          :base,
          error_type.to_sym,
          model_name: record.class.model_name.human,
          model_name_plural: record.class.model_name.plural.humanize,
          start_date: record.start_date,
          end_date: record.end_date,
          count: overlapping_records.size,
          overlapping_records_s: overlapping_records.join(",")
        )
      end
    end

    #TODO add back condition for start_date nil
    #TODO add configuration for span configuration
    def temporally_overlapping_for(record)
      scope = record.instance_eval(&options[:scope])

      start_date = record.start_date || Date.current
      end_date = record.end_date
      arel_table = record.class.arel_table

      if end_date
        scope.where(
          arel_table[:start_date].lteq(end_date).
          and(
            arel_table[:end_date].gteq(start_date).
            or(arel_table[:end_date].eq(nil))
          )
        )
      else
        scope.where(
          arel_table[:end_date].gteq(start_date).
          or(arel_table[:end_date].eq(nil))
        )
      end
    end
  end
end
