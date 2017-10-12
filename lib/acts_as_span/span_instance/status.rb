module ActsAsSpan
  class SpanInstance
    module Status
      extend ActiveSupport::Concern

      included do
        def span_status_on(query_date = Date.current)
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

        def span_status
          span_status_on
        end

        def current_on?(query_date = Date.current)
          !future_on?(query_date) && !expired_on?(query_date)
        end

        def current?
          current_on?
        end

        def future_on?(query_date = Date.current)
          start_date && start_date > query_date
        end

        def future?
          future_on?
        end

        def expired_on?(query_date = Date.current)
          end_date && end_date < query_date
        end

        def expired?
          expired_on?
        end

        def past_on?
          expired_on?
        end

        def past?
          expired?
        end
      end
    end
  end
end
