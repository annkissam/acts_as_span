require 'active_support'

module ActsAsSpan
  class SpanKlass
    module Status
      extend ActiveSupport::Concern

      included do
        #TODO specs and args
        def current_on(query_date = Date.current)
          klass.where(
            (arel_table[start_field].lteq(query_date).or(arel_table[start_field].eq(nil))).
            and(
              arel_table[end_field].eq(nil).or(arel_table[end_field].gteq(query_date))
            )
          )
        end

        def current
          current_on
        end

        def future_on(query_date = Date.current)
          klass.where(arel_table[start_field].gt(query_date))
        end

        def future
          future_on
        end

        def expired_on(query_date = Date.current)
          klass.where(arel_table[end_field].lt(query_date))
        end

        def expired
          expired_on
        end

        def past_on
          expired_on
        end

        def past
          expired
        end

        def current_or_future_on(query_date = Date.current)
          klass.where(
            arel_table[start_field].lteq(query_date).
            and(
              arel_table[end_field].eq(nil).
              or(arel_table[end_field].gteq(query_date))
            ).
            or(arel_table[start_field].gt(query_date))
          )
        end

        def current_or_future
          current_or_future_on
        end
      end
    end
  end
end
