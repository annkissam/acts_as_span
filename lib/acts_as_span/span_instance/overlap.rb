require 'active_support'

module ActsAsSpan
  class SpanInstance
    module Overlap
      extend ActiveSupport::Concern
      
      module InstanceMethods
        #http://stackoverflow.com/questions/699448/ruby-how-do-you-check-whether-a-range-contains-a-subset-of-another-range
        #start_date <= record_end_date && record_start_date <= end_date
        def overlap?(other_span)
          (start_date.nil? || other_span.end_date.nil? || start_date <= other_span.end_date) && (end_date.nil? || other_span.start_date.nil? || other_span.start_date <= end_date)
        end
      end
    end
  end
end