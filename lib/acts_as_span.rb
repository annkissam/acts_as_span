require 'active_support'
require 'ostruct'
require 'forwardable'

ACTS_AS_SPAN_PATH = File.dirname(__FILE__) + "/acts_as_span/"

require ACTS_AS_SPAN_PATH + 'version'
require ACTS_AS_SPAN_PATH + 'span'

module ActsAsSpan
  extend ActiveSupport::Concern
  
  class << self
    def options
      @options ||= {
        :start_date_field => :start_date,
        :end_date_field => :end_date,
        :start_date_field_required => false,
        :end_date_field_required => false,
        :exclude_end => false,
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
      
      self.send(:extend, ActsAsSpan::Scopes)
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
                            :span_status_to_s_on
                            
      validate :validate_spans
    end
    
    def acts_as_span_definitions
      @_acts_as_span_definitions ||= {}
    end
  end
  
  module Scopes
    def overlap(record)
      overlap_for(:default, record)
    end
    
    def overlap_for(name, record)
      record.span_for(name).overlap
    end
  end
  
  module IncludedInstanceMethods
    def span
      span_for(:default)
    end
    
    def span_for(name = :default)
      acts_as_span_instances[name] ||= Span.new(name, self, self.class.acts_as_span_definitions[name])
    end
    
    def acts_as_span_instances
      @_acts_as_span_instances ||= {}
    end
    
    def spans
      self.class.acts_as_span_definitions.keys.map { |acts_as_span_definition| span_for(acts_as_span_definition) }
    end
    
    def validate_spans
      spans.each(&:validate_span)
    end
    
    #NOTE: This uses the default span.
    #  To check a specific span, use record.span_for(:something).overlap?(other_record.span_for(:something_else))
    def overlap?(other_record)
      span.overlap?(other_record.span)
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