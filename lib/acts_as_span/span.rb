require 'forwardable'

require ACTS_AS_SPAN_PATH + 'span/validations'

module ActsAsSpan
  class Span
    extend Forwardable
    
    include ActsAsSpan::Span::Validations
    
    def_delegators :@acts_as_span_definition, :start_date_field,
                                              :end_date_field,
                                              :start_date_field_required,
                                              :end_date_field_required,
                                              :exclude_end,
                                              :span_overlap_scope,
                                              :span_overlap_count
    
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
    
    def span_status(query_date = Date.today)
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
    
    alias_method :span_status_on, :span_status
    
    def span_status_to_s(query_date = Date.today)
      case span_status(query_date)
      when :future
        "Future"
      when :expired
        "Expired"
      when :current
        "Current"
      when :unknown
        "Unknown"
      end
    end
    
    alias_method :span_status_to_s_on, :span_status_to_s
    
    #http://stackoverflow.com/questions/699448/ruby-how-do-you-check-whether-a-range-contains-a-subset-of-another-range
    #start_date <= record_end_date && record_start_date <= end_date
    def overlap?(other_span)
      (start_date.nil? || other_span.end_date.nil? || start_date <= other_span.end_date) && (end_date.nil? || other_span.start_date.nil? || other_span.start_date <= end_date)
    end
    
    def overlap(span_class = span_klass, span_class_span_name = :default)
      span_class_span_definition = span_class.acts_as_span_definitions[span_class_span_name]
      
      span_class_overlap_scope = span_class.where( ["(#{span_class.table_name}.#{span_class_span_definition.start_date_field} IS NULL OR :end_date IS NULL OR #{span_class.table_name}.#{span_class_span_definition.start_date_field} <= :end_date) AND (#{span_class.table_name}.#{span_class_span_definition.end_date_field} IS NULL OR :start_date IS NULL OR :start_date <= #{span_class.table_name}.#{span_class_span_definition.end_date_field})", { :start_date => start_date, :end_date => end_date } ] )
      
      if !span_model.new_record? && span_klass == span_class
        span_class_overlap_scope.where( ["#{span_class.table_name}.id != :id", { :id => span_model.id } ] )
      end
      
      span_class_overlap_scope
    end
  end
end