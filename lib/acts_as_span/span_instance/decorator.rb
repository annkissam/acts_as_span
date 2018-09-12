module ActsAsSpan
  class SpanInstance
    module Decorator
      extend ActiveSupport::Concern

      included do
        def span_to_s
          [start_date, end_date].reject(&:blank?)
                                .map { |x| x.strftime("%m/%d/%Y") }
                                .join(" - ")
        end
      end
    end
  end
end
