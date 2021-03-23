module ActsAsSpan
  class SpanInstance
    module Status
      extend ActiveSupport::Concern

      included do
        def span_status(query_date = Date.current)
          if future?(query_date)
            :future
          elsif expired?(query_date)
            :expired
          elsif current?(query_date)
            :current
          else
            :unknown
          end
        end

        alias_method :span_status_on, :span_status

        def current?(query_date = Date.current)
          !future?(query_date) && !expired?(query_date)
        end

        alias_method :current_on?, :current?

        def future?(query_date = Date.current)
          start_date && start_date > query_date
        end

        alias_method :future_on?, :future?

        def expired?(query_date = Date.current)
          end_date && end_date < query_date
        end

        alias_method :expired_on?, :expired?
        alias_method :past_on?, :expired?
        alias_method :past?, :expired?
      end

      QUERIES = %i[
        future?
        future_on?
        current?
        current_on?
        expired?
        expired_on?
        past?
        past_on?
        span_status
        span_status_on
      ].freeze
    end
  end
end
