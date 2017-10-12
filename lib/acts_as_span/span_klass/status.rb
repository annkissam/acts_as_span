require 'active_support'

module ActsAsSpan
  class SpanKlass
    module Status
      extend ActiveSupport::Concern

      included do
        def current(query_date = Date.current)
          klass.where(
            (arel_table[start_field].lteq(query_date).or(arel_table[start_field].eq(nil))).
            and(
              arel_table[end_field].eq(nil).or(arel_table[end_field].gteq(query_date))
            )
          )
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
      end
    end
  end
end