module ActsAsSpan
  class WithinParentDateSpanValidator < ActiveModel::Validator
    def validate(record)
      parents = options[:parent] || options[:parents]

      error_message = options[:message] || :not_within_parent_date_span

      Array(parents).each do |parent|
        record.errors.add(:base, error_message, parent: record.class.human_attribute_name(parent)) if outside_of_parent_date_span?(record, parent)
      end
    end

    def outside_of_parent_date_span?(record, parent_sym)
      parent = record.send(parent_sym)

      return false if parent.nil?

      start_date_invalid = options[:skip_start_date_validation] ? false : start_date_out_of_span?(record, parent)
      end_date_invalid = options[:skip_end_date_validation] ? false : end_date_out_of_span?(record, parent)

      start_date_invalid || end_date_invalid
    end

    private

    def start_date_out_of_span?(record, parent)
      child_record_without_start_date(record, parent) ||
      child_record_started_before_parent_record(record, parent)
    end

    def end_date_out_of_span?(record, parent)
      child_record_without_end_date(record, parent) ||
      child_record_ended_after_parent_record(record, parent)
    end

    def child_record_started_before_parent_record(record, parent)
      record.span.start_date.present? && parent.span.start_date.present? &&
        record.span.start_date < parent.span.start_date
    end

    def child_record_ended_after_parent_record(record, parent)
      record.span.end_date.present? && parent.span.end_date.present? &&
        record.span.end_date > parent.span.end_date
    end

    def child_record_without_start_date(record, parent)
      record.span.start_date.nil? && parent.span.start_date.present?
    end

    def child_record_without_end_date(record, parent)
      record.span.end_date.nil? && parent.span.end_date.present?
    end
  end
end
