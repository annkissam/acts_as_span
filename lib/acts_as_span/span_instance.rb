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
  end
end
