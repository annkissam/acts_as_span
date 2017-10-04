require 'acts_as_span/span_instance/validations'
require 'acts_as_span/span_instance/status'
require 'acts_as_span/span_instance/overlap'

require 'active_support/core_ext/module/delegation'

module ActsAsSpan
  class SpanInstance
    include ActsAsSpan::SpanInstance::Validations
    include ActsAsSpan::SpanInstance::Status
    include ActsAsSpan::SpanInstance::Overlap

    delegate :start_date_field,
                                              :end_date_field,
                                              :start_date_field_required,
                                              :end_date_field_required,
                                              :exclude_end,
                                              :span_overlap_scope,
                                              :span_overlap_count, to: :@acts_as_span_definition

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
      span_model[start_date_field]
    end

    def end_date
      span_model[end_date_field]
    end
  end
end
