require 'acts_as_span/span_instance/validations'
require 'acts_as_span/span_instance/status'
require 'acts_as_span/span_instance/overlap'

module ActsAsSpan
  class SpanInstance
    extend Forwardable
    
    include ActsAsSpan::SpanInstance::Validations
    include ActsAsSpan::SpanInstance::Status
    include ActsAsSpan::SpanInstance::Overlap
    
    def_delegators :@acts_as_span_definition, :start_date_field,
                                              :end_date_field,
                                              :start_date_field_required,
                                              :end_date_field_required,
                                              :exclude_end,
                                              :span_overlap_scope,
                                              :span_overlap_count
                                              
    def_delegators :span_model, :new_record?
    
    attr_reader :name, :span_model, :acts_as_span_definition
    
    def initialize(name, span_model, acts_as_span_definition)
      @name = name
      @span_model = span_model
      @acts_as_span_definition = acts_as_span_definition
    end
    
    def span_klass
      @span_klass ||= span_model.class
    end
    
    def start_date
      span_model[start_date_field]
    end
    
    def end_date
      span_model[end_date_field]
    end
    
    def close!(close_date = Date.today)
      if end_date.blank?
        span_model.update_attributes!(end_date_field => close_date)
      end
    end
    
    alias_method :close_on!, :close!
  end
end