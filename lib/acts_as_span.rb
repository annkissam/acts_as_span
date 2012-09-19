module ActsAsSpan
  def self.included(base)
    base.send(:extend, ActsAsSpan::NegativeMethods)
    base.send(:include, ActsAsSpan::NegativeMethods)
      
    base.send(:extend, ActsAsSpan::ClassMethods)
  end
  
  module ClassMethods
    def acts_as_span(*args)
      defaults = { :start_date_field => :start_date,
                   :end_date_field => :end_date,
                   :start_date_field_required => false,
                   :end_date_field_required => false,
                   :exclude_end => false,
                   :span_overlap_scope => nil,
                   :span_overlap_count => nil }
                   #:span_overlap_auto_close => false }
      options = args.last.is_a?(Hash) ? defaults.merge(args.pop) : defaults
      #options.assert_valid_keys()
      
      #exclude_end = true   => expired if date == end_date
      #exclude_end = false  => current if date == end_date
      #             Synonym => expired_on_end_date, expire at BEGGINING of end_date
      
      #TODO: Support multiple spans on the same model... :prefix => 'pa'

      case args.length
      when 0
        #uses default value for :start_date_field and :end_date_field
      when 2
        options[:start_date_field] = args[0]
        options[:end_date_field] = args[1]
      else
        raise ArgumentError, "Incorrect number of Arguements provided"
      end
      
      #Make sure the columns exists... But only if the table is already created...
      if table_exists?
        raise ArgumentError, "Column '#{options[:start_date_field]}' does not exist" unless columns_hash[options[:start_date_field].to_s]
        raise ArgumentError, "Column '#{options[:end_date_field]}' does not exist" unless columns_hash[options[:end_date_field].to_s]
      end
      
      cattr_accessor :acts_as_span_options
      self.acts_as_span_options = options
      
      self.send(:include, ActsAsSpan::InstanceMethods)
      self.send(:include, ActsAsSpan::DateAsString)
      self.send(:include, ActsAsSpan::NamedScopes)
      #self.send(:extend, ActsAsSpan::Scopes)
      self.send(:include, ActsAsSpan::Validations)
      
      self.send(:extend, ActsAsSpan::PositiveMethods)
      self.send(:include, ActsAsSpan::PositiveMethods)
    end
  end
  
  module NamedScopes
    def self.included(model)
      model.class_eval do
        scope_method = ActiveRecord::VERSION::MAJOR >= 3 ? :scope : :named_scope
        
        if acts_as_span_options[:exclude_end]
          self.send(scope_method, :current, Proc.new { {:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :query_date OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} > :query_date OR #{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL)", { :query_date => Date.today } ] } })
          self.send(scope_method, :future, Proc.new { {:conditions => ["#{self.table_name}.#{acts_as_span_options[:start_date_field]} > :query_date", { :query_date => Date.today } ] } })
          self.send(scope_method, :expired, Proc.new { {:conditions => ["#{self.table_name}.#{acts_as_span_options[:end_date_field]} <= :query_date", { :query_date => Date.today } ] } })
          
          #Named Scopes to query the span on a date other than Date.today...
          self.send(scope_method, :current_on, Proc.new { |query_date| {:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :query_date OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} > :query_date OR #{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL)", { :query_date => query_date } ] } })
          self.send(scope_method, :future_on, Proc.new { |query_date| {:conditions => ["#{self.table_name}.#{acts_as_span_options[:start_date_field]} > :query_date", { :query_date => query_date } ] } })
          self.send(scope_method, :expired_on, Proc.new { |query_date| {:conditions => ["#{self.table_name}.#{acts_as_span_options[:end_date_field]} <= :query_date", { :query_date => query_date } ] } })
        else
          self.send(scope_method, :current, Proc.new { {:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :query_date OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} >= :query_date OR #{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL)", { :query_date => Date.today } ] } })
          self.send(scope_method, :future, Proc.new { {:conditions => ["#{self.table_name}.#{acts_as_span_options[:start_date_field]} > :query_date", { :query_date => Date.today } ] } })
          self.send(scope_method, :expired, Proc.new { {:conditions => ["#{self.table_name}.#{acts_as_span_options[:end_date_field]} < :query_date", { :query_date => Date.today } ] } })
          
          #Named Scopes to query the span on a date other than Date.today...
          self.send(scope_method, :current_on, Proc.new { |query_date| {:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :query_date OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} >= :query_date OR #{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL)", { :query_date => query_date } ] } })
          self.send(scope_method, :future_on, Proc.new { |query_date| {:conditions => ["#{self.table_name}.#{acts_as_span_options[:start_date_field]} > :query_date", { :query_date => query_date } ] } })
          self.send(scope_method, :expired_on, Proc.new { |query_date| {:conditions => ["#{self.table_name}.#{acts_as_span_options[:end_date_field]} < :query_date", { :query_date => query_date } ] } })
        end
        
        self.send(scope_method, :overlap, Proc.new { |record|
          #raise "TODO" unless record.is_a?(self.class)
          
          record_start_date = record.send(record.acts_as_span_options[:start_date_field])
          record_end_date = record.send(record.acts_as_span_options[:end_date_field])
          
          {:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL OR :record_end_date IS NULL OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :record_end_date) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL OR :record_start_date IS NULL OR :record_start_date <= #{self.table_name}.#{acts_as_span_options[:end_date_field]})", { :record_start_date => record_start_date, :record_end_date => record_end_date } ] } 
          } )
        
        if self.respond_to?(:scope_procedure)
          #Searchlogic can't handle parent.child_record_current_or_future OR parent.child_record_current_or_child_record_future
          #It can handle parent.child_record_current_xor_future
          scope_procedure :current_xor_future, lambda { current_or_future }
        end
      end
    end
  end
  
  #module Scopes
  #  def current(date = Date.today)
  #    scoped(:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :date OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} > :date OR #{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL)", { :date => date } ] )
  #  end
  #  
  #  def future(date = Date.today)
  #    scoped(:conditions => ["#{self.table_name}.#{acts_as_span_options[:start_date_field]} > :date", { :date => date } ] )
  #  end
  #  
  #  def expired(date = Date.today)
  #    scoped(:conditions => ["#{self.table_name}.#{acts_as_span_options[:end_date_field]} <= :date", { :date => date } ] ) 
  #  end
  #  
  #  def current_on(date)
  #    current(date)
  #  end
  #  
  #  def future_on(date)
  #    future(date)
  #  end
  #  
  #  def expired_on(date)
  #    expired(date)
  #  end
  #end
  
  module DateAsString
    def self.included(model)
      model.class_eval do
        if self.respond_to?(:date_as_string)
          date_as_string acts_as_span_options[:start_date_field]
          date_as_string acts_as_span_options[:end_date_field]
        end
      end
    end
  end
  
  module Validations
    def self.included(model)
      model.class_eval do
        #before_validation_on_create :add_start_date
        validate :validate_span
      end
    end
  end
  
  module InstanceMethods
    def current?(query_date = Date.today)
      !future?(query_date) && !expired?(query_date)
    end

    def future?(query_date = Date.today)
      start_date = self.send(acts_as_span_options[:start_date_field])
      
      start_date && start_date > query_date
    end

    def expired?(query_date = Date.today)
      end_date = self.send(acts_as_span_options[:end_date_field])
      exclude_end = acts_as_span_options[:exclude_end]
      
      if exclude_end
        end_date && end_date <= query_date
      else
        end_date && end_date < query_date
      end
    end
    
    def starting?(query_date = Date.today)
      start_date = self.send(acts_as_span_options[:start_date_field])
      
      start_date == query_date
    end
    
    def ending?(query_date = Date.today)
      end_date = self.send(acts_as_span_options[:end_date_field])
      
      end_date == query_date
    end
    
    #Methods to query the span on a date other than Date.today...
    def current_on?(query_date)
      current?(query_date)
    end

    def future_on?(query_date)
      future?(query_date)
    end

    def expired_on?(query_date)
      expired?(query_date)
    end
    
    def starting_on?(query_date)
      starting?(query_date)
    end
    
    def ending_on?(query_date)
      ending?(query_date)
    end
    
    def close!(close_date=Date.today)
      if self.send(acts_as_span_options[:end_date_field]).blank?
        self.update_attributes!(acts_as_span_options[:end_date_field] => close_date)
      end
    end
    
    def span_status
      if future?
        :future
      elsif expired?
        :expired
      elsif current?
        :current
      else
        :unknown
      end
    end

    def span_status_to_s
      case span_status
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
    
    #This defaults nil to Date.today - Is that really the correct behavior?
    def to_date_range
      start_date = self.send(acts_as_span_options[:start_date_field])
      start_date = Date.today if start_date.blank?
      end_date = self.send(acts_as_span_options[:end_date_field])
      end_date = Date.today if end_date.blank?
      
      start_date..end_date
    end
    
    def validate_span
      #We're just mapping these to temporary variables for ease of use
      start_date_field = acts_as_span_options[:start_date_field]
      end_date_field = acts_as_span_options[:end_date_field]
      
      start_date_field_required = acts_as_span_options[:start_date_field_required]
      end_date_field_required = acts_as_span_options[:end_date_field_required]
      
      start_date = self.send(start_date_field)
      end_date = self.send(end_date_field)
      
      if start_date_field_required && start_date.blank?
        errors.add(start_date_field, :blank)
      end
      
      if end_date_field_required && end_date.blank?
        errors.add(end_date_field, :blank)
      end
      
      if start_date && end_date && end_date < start_date
        errors.add(end_date_field, "Must be on or after #{start_date_field}")
      end
      
      if (acts_as_span_options[:span_overlap_count] || acts_as_span_options[:span_overlap_scope]) && errors[start_date_field].blank? && errors[end_date_field].blank? && ( respond_to?('archived?') ? !archived? : true )
        conditions = {}
        
        span_overlap_scope = acts_as_span_options[:span_overlap_scope]
        
        if span_overlap_scope.is_a?(Array)
          span_overlap_scope.each do |symbol|
            conditions[symbol] = send(symbol)
          end
        elsif span_overlap_scope.is_a?(Symbol)
          conditions[span_overlap_scope] = send(span_overlap_scope)
        end
        
        if self.class.respond_to?('not_archived')
          records = self.class.not_archived.overlap(self).all(:conditions => conditions)
        else
          records = self.class.overlap(self).all(:conditions => conditions)
        end
        
        records = records.reject {|record| record == self }
        
        #TODO - This will have to be an after_save callback...
        #if acts_as_span_options[:span_overlap_auto_close]
        #  records.each do |record|
        #    record.close!(start_date)
        #  end
        #end
                
        if records.count > (acts_as_span_options[:span_overlap_count] || 0)
          ActiveRecord::VERSION::MAJOR >= 3 ?  errors.add(:base, :overlaps) : errors.add_to_base(:overlaps)
        end
      end
    end
    
    def overlap?(record)
      #raise "TODO" unless record.is_a?(self.class)
      
      start_date = self.send(acts_as_span_options[:start_date_field])
      end_date = self.send(acts_as_span_options[:end_date_field])
      
      record_start_date = record.send(record.acts_as_span_options[:start_date_field])
      record_end_date = record.send(record.acts_as_span_options[:end_date_field])
      
      #http://stackoverflow.com/questions/699448/ruby-how-do-you-check-whether-a-range-contains-a-subset-of-another-range
      #start_date <= record_end_date && record_start_date <= end_date
      
      (start_date.nil? || record_end_date.nil? || start_date <= record_end_date) && (end_date.nil? || record_start_date.nil? || record_start_date <= end_date)
    end
  end
  
  #negative/positive methods are used for testing... 
  module PositiveMethods
    send(:define_method, "acts_as_span?") do
      true
    end
  end
  
  module NegativeMethods
    send(:define_method, "acts_as_span?") do
      false
    end
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, ActsAsSpan)
end