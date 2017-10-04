require 'active_support'

module ActsAsSpan
  class SpanKlass
    module Status
      extend ActiveSupport::Concern

      included do
        def current(query_date = Date.today)
          klass.where(["(#{table_name}.#{start_date_field} <= :query_date OR #{table_name}.#{start_date_field} IS NULL) AND (#{table_name}.#{end_date_field} >= :query_date OR #{table_name}.#{end_date_field} IS NULL)", { :query_date => query_date } ] )
        end

        alias_method :current_on, :current

        def future(query_date = Date.today)
          klass.where(["#{table_name}.#{start_date_field} > :query_date", { :query_date => query_date } ] )
        end

        alias_method :future_on, :future

        def expired(query_date = Date.today)
          klass.where(["#{table_name}.#{end_date_field} < :query_date", { :query_date => query_date } ] )
        end

        alias_method :expired_on, :expired
      end
    end
  end
end
