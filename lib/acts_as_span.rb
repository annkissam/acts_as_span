require 'ostruct'
require 'acts_as_span/version'
require 'acts_as_span/span_klass'
require 'acts_as_span/span_instance'

require 'active_support'
require 'active_record'

module ActsAsSpan
  extend ActiveSupport::Concern

  class << self
    def options
      @options ||= {
        :start_field => :start_date,
        :end_field => :end_date,
        :span_overlap_scope => nil,
        :span_overlap_count => nil,
        :name => :default
      }
    end

    def configure
      yield(self) if block_given?
    end
  end

  module ClassMethods
    def acts_as_span(*args)
      self.send(:extend, ActsAsSpan::ExtendedClassMethods)
      self.send(:include, ActsAsSpan::IncludedInstanceMethods)

      options = OpenStruct.new(args.last.is_a?(Hash) ? ActsAsSpan.options.merge(args.pop) : ActsAsSpan.options)

      #if span_overlap_scope is specified the span_overlap_count defaults to 0
      options.span_overlap_count ||= 0 if options.span_overlap_scope

      acts_as_span_definitions[options.name] = options

      delegate :span_status,
               :span_status_on,
               :current?,
               :current_on?,
               :future?,
               :future_on?,
               :expired?,
               :expired_on?, to: :span

      delegate :acts_as_span_definitions, to: :class

      class << self
        delegate :current,
                 :current_on,
                 :future,
                 :future_on,
                 :expired,
                 :expired_on, to: :span
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
end

ActiveRecord::Base.send(:include, ActsAsSpan)
