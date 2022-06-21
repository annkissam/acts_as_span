require 'acts_as_span/span_instance/validations'
require 'acts_as_span/span_instance/status'

require 'active_support/core_ext/module/delegation'

module ActsAsSpan
  class SpanInstance
    include ActsAsSpan::SpanInstance::Validations
    include ActsAsSpan::SpanInstance::Status

    delegate :start_field,
             :end_field,
             :exclude_end, to: :@acts_as_span_definition

    delegate :new_record?, to: :span_model

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
      span_model[start_field]
    end

    def end_date
      span_model[end_field]
    end

    def start_date_changed?
      span_model.will_save_change_to_attribute?(start_field)
    end

    def end_date_changed?
      span_model.will_save_change_to_attribute?(end_field)
    end

    # @param other [ActsAsSpan::SpanInstance]
    # @return [Boolean]
    def overlap?(other)
      other.actual_start_date <= actual_end_date && actual_start_date <= other.actual_end_date
    end

    protected

    def actual_end_date
      end_date || Date::Infinity.new
    end

    def actual_start_date
      start_date || Date.current
    end
  end
end
