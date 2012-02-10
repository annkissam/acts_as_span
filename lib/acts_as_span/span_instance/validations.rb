module ActsAsSpan
  class SpanInstance
    module Validations
      extend ActiveSupport::Concern
      
      module InstanceMethods
        def validate
          validate_start_date
          validate_end_date
          validate_start_date_less_than_or_equal_to_end_date
          validate_overlap
        end
        
        def validate_start_date
          if start_date_field_required && start_date.blank?
            span_model.errors.add(start_date_field, :blank)
          end
        end
        
        def validate_end_date
          if end_date_field_required && end_date.blank?
            span_model.errors.add(end_date_field, :blank)
          end
        end
        
        def validate_start_date_less_than_or_equal_to_end_date
          if start_date && end_date && end_date < start_date
            span_model.errors.add(end_date_field, "Must be on or after #{start_date_field}")
          end
        end

        def validate_overlap
          if span_overlap_count && span_model.errors[start_date_field].empty? && span_model.errors[end_date_field].empty? # && ( respond_to?('archived?') ? !archived? : true )
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

            #TODO - This will have to be an after_save callback...
            #if span_overlap_auto_close
            #  records.each do |record|
            #    record.close!(start_date)
            #  end
            #end

            if records.count > span_overlap_count
              span_model.errors.add(:base, "date range overlaps with #{records.count} other record(s)")
            end
          end
        end
      end
    end
  end
end