require 'forwardable'

module ActsAsSpan
  class Span
    extend Forwardable
    
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
    
    def validate_span
      if start_date_field_required && start_date.blank?
        span_model.errors.add(start_date_field, :blank)
      end
      
      if end_date_field_required && end_date.blank?
        span_model.errors.add(end_date_field, :blank)
      end
      
      if start_date && end_date && end_date < start_date
        span_model.errors.add(end_date_field, "Must be on or after #{start_date_field}")
      end
      
      validate_overlap
    end
    
    def validate_overlap
      if span_overlap_count && span_model.errors[start_date_field].empty? && span_model.errors[end_date_field].empty? # && ( respond_to?('archived?') ? !archived? : true )
        conditions = {}
        
        if span_overlap_scope.is_a?(Array)
          span_overlap_scope.each do |symbol|
            conditions[symbol] = span_model.send(symbol)
          end
        elsif span_overlap_scope.is_a?(Symbol)
          conditions[span_overlap_scope] = span_model.send(span_overlap_scope)
        end
        
        records = overlap.where(conditions)
        
        if span_klass.respond_to?('not_archived')
          records.not_archived
        end
        
        #TODO - This will have to be an after_save callback...
        #if span_overlap_auto_close
        #  records.each do |record|
        #    record.close!(start_date)
        #  end
        #end
        
        if records.count > span_overlap_count
          span_model.errors.add(:base, "date range overlaps with #{records.count} other record(s)\n#{overlap.to_sql}")
        end
      end
    end
    
    #http://stackoverflow.com/questions/699448/ruby-how-do-you-check-whether-a-range-contains-a-subset-of-another-range
    #start_date <= record_end_date && record_start_date <= end_date
    def overlap?(other_span)
      (start_date.nil? || other_span.end_date.nil? || start_date <= other_span.end_date) && (end_date.nil? || other_span.start_date.nil? || other_span.start_date <= end_date)
    end
    
    def overlap
      span_klass_overlap_scope = span_klass.where( ["(#{span_klass.table_name}.#{start_date_field} IS NULL OR :end_date IS NULL OR #{span_klass.table_name}.#{start_date_field} <= :end_date) AND (#{span_klass.table_name}.#{end_date_field} IS NULL OR :start_date IS NULL OR :start_date <= #{span_klass.table_name}.#{end_date_field})", { :start_date => start_date, :end_date => end_date } ] )
      
      unless span_model.new_record?
        span_klass_overlap_scope.where( ["#{span_klass.table_name}.id != :id", { :id => span_model.id } ] )
      end
      
      span_klass_overlap_scope
    end
  end
end