# frozen_string_literal: true

require 'ostruct'
require 'acts_as_span/version'
require 'acts_as_span/span_klass'
require 'acts_as_span/span_instance'

require 'acts_as_span/no_overlap_validator'
require 'acts_as_span/within_parent_date_span_validator'

require 'acts_as_span/end_date_propagator'

require 'active_support'
require 'active_record'

I18n.load_path += Dir[File.join(File.dirname(__dir__), 'config', 'locales', '**', 'acts_as_span.yml')]

module ActsAsSpan
  extend ActiveSupport::Concern

  OPTIONS = %i[start_field end_field name].freeze

  class << self
    def options
      @options ||= {
        start_field: :start_date,
        end_field: :end_date,
        name: :default,
      }
    end

    def configure
      yield(self) if block_given?
    end
  end

  module ClassMethods
    def acts_as_span(*args)
      send(:extend, ActsAsSpan::ExtendedClassMethods)
      send(:include, ActsAsSpan::IncludedInstanceMethods)

      # TODO: There's some refactoring that could be done here using keyword args (or the more standard old hash arg pattern)
      options = OpenStruct.new(args.last.is_a?(Hash) ? ActsAsSpan.options.merge(args.pop) : ActsAsSpan.options)

      unsupported_options =
        options.to_h.keys.reject { |opt| OPTIONS.include? opt }
      unless unsupported_options.empty?
        raise ArgumentError,
              "Unsupported option(s): #{unsupported_options.map { |o| "'#{o}'" }.join(', ')}"
      end

      acts_as_span_definitions[options.name] = options

      # add methods like `current_on?` to an instance
      delegate(*ActsAsSpan::SpanInstance::Status::QUERIES, to: :span)

      delegate :acts_as_span_definitions, to: :class

      class << self
        # add methods like `current` to a class
        delegate(*ActsAsSpan::SpanKlass::Status::SCOPES, to: :span)
        # expose all scope method names to the application for use in, for
        #   example, Ransack
        delegate(:span_scopes, to: :span)

        # add methods like 'latest' to a class
        delegate(
          *ActsAsSpan::SpanKlass::Superlatives::METHOD_SYMBOLS,
          to: :span,
        )
      end

      validate :validate_spans
    end

    def acts_as_span_definitions
      @_acts_as_span_definitions ||= {}
    end
  end

  module ExtendedClassMethods
    def spans
      acts_as_span_definitions.keys.map do |acts_as_span_definition_name|
        span_for(acts_as_span_definition_name)
      end
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
      acts_as_span_definitions.keys.map do |acts_as_span_definition_name|
        span_for(acts_as_span_definition_name)
      end
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
  end
end

ActiveRecord::Base.include ActsAsSpan if Object.const_defined?('ActiveRecord')
