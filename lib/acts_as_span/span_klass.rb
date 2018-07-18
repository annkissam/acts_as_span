require 'acts_as_span/span_klass/status'

require 'active_support/core_ext/module/delegation'

module ActsAsSpan
  class SpanKlass
    include ActsAsSpan::SpanKlass::Status

    delegate :start_field,
             :end_field,
             :exclude_end, to: :@acts_as_span_definition

    delegate :table_name, :arel_table, to: :klass, allow_nil: true

    attr_reader :name, :klass, :acts_as_span_definition

    def initialize(name, klass, acts_as_span_definition)
      @name = name
      @klass = klass
      @acts_as_span_definition = acts_as_span_definition
    end
  end
end
