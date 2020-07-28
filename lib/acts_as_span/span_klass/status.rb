require 'active_support'

module ActsAsSpan
  class SpanKlass
    module Status
      extend ActiveSupport::Concern

      included do
        def current(query_date = Date.current)
          klass.where(
            current_condition(query_date: query_date, table: arel_table)
          )
        end

        def current_condition(query_date:, table:)
          start_col = arel_table[start_field]
          end_col = arel_table[end_field]

          start_condition = start_col.lteq(query_date).or(start_col.eq(nil))
          end_condition = end_col.eq(nil).or(end_col.gteq(query_date))

          start_condition.and(end_condition)
        end

        alias_method :current_on, :current

        def future(query_date = Date.current)
          klass.where(arel_table[start_field].gt(query_date))
        end

        alias_method :future_on, :future

        def expired(query_date = Date.current)
          klass.where(arel_table[end_field].lt(query_date))
        end

        alias_method :expired_on, :expired
        alias_method :past_on, :expired
        alias_method :past, :expired


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

        alias_method :current_or_future, :current_or_future_on
      end
    end
  end
end
