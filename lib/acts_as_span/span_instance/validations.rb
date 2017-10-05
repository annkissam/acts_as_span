module ActsAsSpan
  class SpanInstance
    module Validations
      extend ActiveSupport::Concern

      included do
        def validate
          validate_start_date_less_than_or_equal_to_end_date
        end

        def validate_start_date_less_than_or_equal_to_end_date
          if start_date && end_date && end_date < start_date
            span_model.errors.add(end_field, "Must be on or after #{start_field}")
          end
        end
      end
    end
  end
end
