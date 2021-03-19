# frozen_string_Literal: true

require 'active_support'

module ActsAsSpan
  class SpanKlass
    # Defines class-level methods for relative span scopes.
    #
    # The *_condition methods return Arel nodes for composition purposes.
    #
    # They accept keyword arguments:
    #
    # * query_date: a Date object, the reference date
    # * table: an Arel table, the table whose columns will be used
    #
    # `table` can also be Arel::Nodes::TableAlias
    module Status
      extend ActiveSupport::Concern

      included do
        # Records whose spans include the query date.
        # If no query date is given, the current date is the query date.
        # Date span is _inclusive_: if the query date is equal to the
        #   span start or end date, that span counts as current.
        def current(query_date = Date.current)
          klass.where(
            current_condition(query_date: query_date, table: arel_table),
          )
        end

        alias_method :current_on, :current

        # Records whose spans start strictly after the query date.
        # If no query date is given, the current date is the query date.
        def future(query_date = Date.current)
          klass.where(
            future_condition(query_date: query_date, table: arel_table),
          )
        end

        alias_method :future_on, :future

        # Records whose spans end strictly before the query date.
        # If no query date is given, the current date is the query date.
        def expired(query_date = Date.current)
          klass.where(
            expired_condition(query_date: query_date, table: arel_table),
          )
        end

        alias_method :expired_on, :expired
        alias_method :past_on, :expired
        alias_method :past, :expired

        # Records whose spans include the query date, or start after the query
        #   date.
        # If no query date is given, the current date is the query date.
        # Records are excluded from the result only if they are expired.
        def current_or_future_on(query_date = Date.current)
          current_cond =
            current_condition(query_date: query_date, table: arel_table)
          future_cond =
            future_condition(query_date: query_date, table: arel_table)

          klass.where(current_cond.or(future_cond))
        end

        alias_method :current_or_future, :current_or_future_on

        def current_condition(query_date:, table:)
          start_col = table[start_field]
          end_col = table[end_field]

          start_condition = start_col.lteq(query_date).or(start_col.eq(nil))
          end_condition = end_col.eq(nil).or(end_col.gteq(query_date))

          start_condition.and(end_condition)
        end

        def expired_condition(query_date:, table:)
          table[end_field].lt(query_date)
        end

        def future_condition(query_date:, table:)
          table[start_field].gt(query_date)
        end
      end
    end
  end
end
