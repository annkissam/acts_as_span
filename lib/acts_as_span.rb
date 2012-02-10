require 'active_support'
require 'ostruct'
require 'forwardable'

require 'acts_as_span/version'
require 'acts_as_span/span_klass'
require 'acts_as_span/span_instance'

module ActsAsSpan
  extend ActiveSupport::Concern
  
  class << self
    def options
      @options ||= {
        :start_date_field => :start_date,
        :end_date_field => :end_date,
        :start_date_field_required => false,
        :end_date_field_required => false,
        :span_overlap_scope => nil,
        :span_overlap_count => nil,
        :name => :default
      }
    end
    
    def configure
      yield(self) if block_given?
    end
  end
  
  #by default, all model classess & their instances will return false w/ acts_as_span?
  included do
    self.send(:extend, ActsAsSpan::NegativeMethods)
    self.send(:include, ActsAsSpan::NegativeMethods)
  end
  
  module ClassMethods
    def acts_as_span(*args)
      #this model & its instances will return true w/ acts_as_span?
      self.send(:extend, ActsAsSpan::PositiveMethods)
      self.send(:include, ActsAsSpan::PositiveMethods)
      
      self.send(:extend, Forwardable)
      
      self.send(:extend, ActsAsSpan::ExtendedClassMethods)
      self.send(:include, ActsAsSpan::IncludedInstanceMethods)
      
      options = OpenStruct.new(args.last.is_a?(Hash) ? ActsAsSpan.options.merge(args.pop) : ActsAsSpan.options)
      
      #if span_overlap_scope is specified the span_overlap_count defaults to 0
      options.span_overlap_count ||= 0 if options.span_overlap_scope
      
      acts_as_span_definitions[options.name] = options
      
      def_delegators :span, :close!,
                            :close_on!,
                            :span_status,
                            :span_status_on,
                            :span_status_to_s,
                            :span_status_to_s_on,
                            :current?,
                            :current_on?,
                            :future?,
                            :future_on?,
                            :expired?,
                            :expired_on?
                            
      def_delegators 'self.class', :acts_as_span_definitions
      
      class << self
        self.send(:extend, Forwardable)
        
        def_delegators :span, :current,
                              :current_on,
                              :future,
                              :future_on,
                              :expired,
                              :expired_on
      end
      
      validate :validate_spans
    end
    
    def acts_as_span_definitions
      @_acts_as_span_definitions ||= {}
    end
  end
  
  module ExtendedClassMethods
    def overlap(test_record)
      overlap_for(test_record, :default, :default)
    end
    
    def overlap_for(test_record, test_record_span_name = :default, this_span_name = :default)
      span_for(this_span_name).overlap(test_record.span_for(test_record_span_name))
    end
    
    def spans
      acts_as_span_definitions.keys.map { |acts_as_span_definition_name| span_for(acts_as_span_definition_name) }
    end
    
    def span
      span_for(:default)
    end
    
    def span_for(name = :default)
      acts_as_span_klasses[name] ||= SpanKlass.new(name, self, acts_as_span_definitions[name])
    end
    
    def acts_as_span_klasses
      @_acts_as_span_klasses ||= {}
    end
  end
  
  module IncludedInstanceMethods
    def spans
      acts_as_span_definitions.keys.map { |acts_as_span_definition_name| span_for(acts_as_span_definition_name) }
    end
    
    def span
      span_for(:default)
    end
    
    def span_for(name = :default)
      acts_as_span_instances[name] ||= SpanInstance.new(name, self, acts_as_span_definitions[name])
    end
    
    def acts_as_span_instances
      @_acts_as_span_instances ||= {}
    end
    
    def validate_spans
      spans.each(&:validate)
    end
    
    #This syntax assumes :default span
    def overlap?(other_record)
      overlap_for?(other_record, :default, :default)
    end
    
    #record.span_for(:this_span_name).overlap?(other_record.span_for(:other_record_span_name))
    def overlap_for?(other_record, this_span_name = :default, other_record_span_name = :default)
      span_for(this_span_name).overlap?(other_record.span_for(other_record_span_name))
    end
  end
  
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

ActiveRecord::Base.send(:include, ActsAsSpan)