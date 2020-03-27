require 'active_model'

module ActsAsSpan
  class NoOverlapValidator < ActiveModel::Validator
    def validate(record)
      overlapping_records = temporally_overlapping_for(record)
      instance_scope = if options[:instance_scope].is_a? Proc
                         record.instance_eval&options[:instance_scope]
                       else
                         true
                       end

      if overlapping_records.any? && instance_scope

        error_type = if overlapping_records.size == 1
                       "no_overlap.one"
                     else
                       "no_overlap.other"
                     end

        record.errors.add(
          :base,
          error_type.to_sym,
          model_name: record.class.model_name.human,
          model_name_plural: record.class.model_name.plural.humanize,
          start_date: record.span.start_date,
          end_date: record.span.end_date,
          count: overlapping_records.size,
          overlapping_records_s: overlapping_records.join(",")
        )
      end
    end

    #TODO add back condition for start_date nil
    #TODO add support for multiple spans (currently only checks :default)
    def temporally_overlapping_for(record)
      scope = record.instance_eval(&options[:scope])

      start_date = record.span.start_date || Date.current
      end_date = record.span.end_date
      arel_table = record.class.arel_table

      if end_date
        scope.where(
          arel_table[record.span.start_field].lteq(end_date)
          .and(
            arel_table[record.span.end_field].gteq(start_date)
          .or(arel_table[record.span.end_field].eq(nil))
          )
        )
      else
        scope.where(
          arel_table[record.span.end_field].gteq(start_date)
          .or(arel_table[record.span.end_field].eq(nil))
        )
      end
    end
  end
end
