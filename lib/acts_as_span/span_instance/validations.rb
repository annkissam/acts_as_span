module ActsAsSpan
  class SpanInstance
    module Validations
      extend ActiveSupport::Concern

      included do
        def validate
          validate_start_date_less_than_or_equal_to_end_date
          validate_overlap
        end

        def validate_start_date_less_than_or_equal_to_end_date
          if start_date && end_date && end_date < start_date
            span_model.errors.add(end_field, "Must be on or after #{start_field}")
          end
        end

        def validate_overlap
          if span_overlap_count && span_model.errors[start_field].empty? && span_model.errors[end_field].empty? # && ( respond_to?('archived?') ? !archived? : true )
            conditions = {}

            if span_overlap_scope.is_a?(Array)
              span_overlap_scope.each do |symbol|
                conditions[symbol] = span_model.send(symbol)
              end
            elsif span_overlap_scope.is_a?(Symbol)
              conditions[span_overlap_scope] = span_model.send(span_overlap_scope)
            end

            records = span_klass.span_for(name).overlap(self).where(conditions)

            if span_klass.respond_to?('not_archived')
              records.not_archived
            end

            if records.count > span_overlap_count
              span_model.errors.add(:base, "date range overlaps with #{records.count} other record(s)")
            end
          end
        end
      end
    end
  end
end
