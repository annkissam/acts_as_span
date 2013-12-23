module ActsAsSpan
  class SpanKlass
    module Overlap
      extend ActiveSupport::Concern

      module InstanceMethods
        def overlap(test_span)
          overlap_scope = klass.where( ["(#{table_name}.#{start_date_field} IS NULL OR :end_date IS NULL OR #{table_name}.#{start_date_field} <= :end_date) AND (#{table_name}.#{end_date_field} IS NULL OR :start_date IS NULL OR :start_date <= #{table_name}.#{end_date_field})", { :start_date => test_span.start_date, :end_date => test_span.end_date } ] )

          if !test_span.new_record? && test_span.span_klass == klass
            overlap_scope.where( ["#{table_name}.id <> :id", { :id => test_span.span_model.id } ] )
          end

          overlap_scope
        end
      end
    end
  end
end
