require 'forwardable'

require ACTS_AS_SPAN_PATH + 'span_klass/status'
require ACTS_AS_SPAN_PATH + 'span_klass/overlap'

module ActsAsSpan
  class SpanKlass
    extend Forwardable
    
    include ActsAsSpan::SpanKlass::Status
    include ActsAsSpan::SpanKlass::Overlap
    
    def_delegators :@acts_as_span_definition, :start_date_field,
                                              :end_date_field,
                                              :start_date_field_required,
                                              :end_date_field_required,
                                              :exclude_end,
                                              :span_overlap_scope,
                                              :span_overlap_count
    
    def_delegators :klass, :table_name
    
    attr_reader :name, :klass, :acts_as_span_definition
    
    def initialize(name, klass, acts_as_span_definition)
      @name = name
      @klass = klass
      @acts_as_span_definition = acts_as_span_definition
    end
  end
end