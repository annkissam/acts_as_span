module ActsAsSpan
  class WithinParentDateSpanValidator < ActiveModel::Validator
    def validate(record)
      parents = options[:parent] || options[:parents]

      Array(parents).each do |parent|
        record.errors.add(:base, :not_within_parent_date_span, parent: record.class.human_attribute_name(parent)) if outside_of_parent_date_span?(record, parent)
      end
    end

    def outside_of_parent_date_span?(record, parent_sym)
      parent = record.send(parent_sym)

      return false if parent.nil?

        child_record_without_start_date(record, parent) ||
        child_record_without_end_date(record, parent) ||
        child_record_started_before_parent_record(record, parent) ||
          child_record_ended_after_parent_record(record, parent)
    end

    private

    def child_record_started_before_parent_record(record, parent)
      record.start_date.present? && parent.start_date.present? &&
        record.start_date < parent.start_date
    end

    def child_record_ended_after_parent_record(record, parent)
      record.end_date.present? && parent.end_date.present? &&
        record.end_date > parent.end_date
    end

    def child_record_without_start_date(record, parent)
      record.start_date.nil? && parent.start_date.present?
    end

    def child_record_without_end_date(record, parent)
      record.end_date.nil? && parent.end_date.present?
    end
  end
end
