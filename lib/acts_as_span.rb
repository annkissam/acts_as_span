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
                   :exclude_end => false }
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
        if acts_as_span_options[:exclude_end]
          named_scope :current, Proc.new { {:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :query_date OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} > :query_date OR #{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL)", { :query_date => Date.today } ] } }
          named_scope :future, Proc.new { {:conditions => ["#{self.table_name}.#{acts_as_span_options[:start_date_field]} > :query_date", { :query_date => Date.today } ] } }
          named_scope :expired, Proc.new { {:conditions => ["#{self.table_name}.#{acts_as_span_options[:end_date_field]} <= :query_date", { :query_date => Date.today } ] } }
          
          #Named Scopes to query the span on a date other than Date.today...
          named_scope :current_on, Proc.new { |query_date| {:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :query_date OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} > :query_date OR #{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL)", { :query_date => query_date } ] } }
          named_scope :future_on, Proc.new { |query_date| {:conditions => ["#{self.table_name}.#{acts_as_span_options[:start_date_field]} > :query_date", { :query_date => query_date } ] } }
          named_scope :expired_on, Proc.new { |query_date| {:conditions => ["#{self.table_name}.#{acts_as_span_options[:end_date_field]} <= :query_date", { :query_date => query_date } ] } }
        else
          named_scope :current, Proc.new { {:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :query_date OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} >= :query_date OR #{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL)", { :query_date => Date.today } ] } }
          named_scope :future, Proc.new { {:conditions => ["#{self.table_name}.#{acts_as_span_options[:start_date_field]} > :query_date", { :query_date => Date.today } ] } }
          named_scope :expired, Proc.new { {:conditions => ["#{self.table_name}.#{acts_as_span_options[:end_date_field]} < :query_date", { :query_date => Date.today } ] } }
          
          #Named Scopes to query the span on a date other than Date.today...
          named_scope :current_on, Proc.new { |query_date| {:conditions => ["(#{self.table_name}.#{acts_as_span_options[:start_date_field]} <= :query_date OR #{self.table_name}.#{acts_as_span_options[:start_date_field]} IS NULL) AND (#{self.table_name}.#{acts_as_span_options[:end_date_field]} >= :query_date OR #{self.table_name}.#{acts_as_span_options[:end_date_field]} IS NULL)", { :query_date => query_date } ] } }
          named_scope :future_on, Proc.new { |query_date| {:conditions => ["#{self.table_name}.#{acts_as_span_options[:start_date_field]} > :query_date", { :query_date => query_date } ] } }
          named_scope :expired_on, Proc.new { |query_date| {:conditions => ["#{self.table_name}.#{acts_as_span_options[:end_date_field]} < :query_date", { :query_date => query_date } ] } }
        end
        
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
      #(start_date.nil? || start_date <= Date.today) && (end_date.nil? || end_date > Date.today)
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
    
    #If there was no param[:start_date_string], set to default
    #Note, this is different than blank!
    #if a form has a start_date_string - don't set this
    #if a form does not have a start_date_string - set this
    #def add_start_date
    #  return unless acts_as_span_options[:add_start_date_if_start_date_string_is_nil] && self.send(acts_as_span_options[:start_date_field]).blank?
    #  self.send("#{acts_as_span_options[:start_date_field]}=", Date.today)
    #  start_date = Date.today if start_date_string.nil?
    #end
    
    def validate_span
      start_date = self.send(acts_as_span_options[:start_date_field])
      end_date = self.send(acts_as_span_options[:end_date_field])
      
      if acts_as_span_options[:start_date_field_required] && start_date.blank?
        errors.add(acts_as_span_options[:start_date_field], :blank)
      end
      
      if acts_as_span_options[:end_date_field_required] && end_date.blank?
        errors.add(acts_as_span_options[:end_date_field], :blank)
      end
      
      #if start_date && end_date && end_date <= start_date
      if start_date && end_date && end_date < start_date
        errors.add(acts_as_span_options[:end_date_field], "Must be after #{acts_as_span_options[:start_date_field]}")
      end
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

=begin
  def acts_as_span(options={})
    module_eval <<-EOF
      date_as_string :start_date, :default => "Date.today.strftime('%m/%d/%Y')"
      date_as_string :end_date
  
      validate :valid_dates
  
      def valid_dates
        return unless errors.on(:start_date_string).nil?
  
        errors.add(:start_date_string, :blank) unless start_date || _acts_as_span_options[:require_start_date] == false 
        errors.add(:end_date_string, 'must be after Start Date') if end_date && errors.on(:end_date_string).nil? && ((start_date && end_date < start_date) || (start_date.nil?))
      end
  
      def to_date_range
        if end_date
          start_date..end_date
        else
          start_date..Date.today
        end
      end
          
    EOF
  
    if options[:exclude_overlapping_spans]
      if options[:exclude_overlapping_spans].is_a?(Array)
        attributes = []
        options[:exclude_overlapping_spans].each {|attribute| attributes << "!#{attribute}.blank?"}
        attributes_required_string = attributes.join(' && ')
        scopes = []
        options[:exclude_overlapping_spans].each {|scope| scopes << "#{scope}_is(#{scope})" }
        scope = scopes.join('.')  
      else
        attributes_required_string = true
        scope = 'all'
      end
  
      module_eval <<-EOF
        validate                    :exclude_overlapping_spans
  
        def exclude_overlapping_spans
          return unless #{attributes_required_string} && start_date && errors.on(:start_date_string).nil? && errors.on(:end_date_string).nil?
  
          #{self.name}.#{scope}.each do |record|
            next if record == self
            next if record.respond_to?('archived?') && record.archived?
  
            #{'record.update_attribute(:end_date, start_date) if record.end_date.nil? && record.start_date <= start_date' if options[:auto_close] }
  
            if record.start_date && record.end_date
              if end_date 
                return errors.add(:date_range, :overlaps) unless (start_date <= record.start_date && end_date <= record.start_date) || (start_date >= record.end_date && end_date >= record.end_date)
              else
                return errors.add(:date_range, :overlaps) unless start_date >= record.end_date
              end  
            elsif record.start_date && end_date
              return errors.add(:date_range, :overlaps) unless end_date <= record.start_date
            else
              return errors.add(:date_range, :overlaps)
            end    
          end    
        end
      EOF
    end
  end
=end