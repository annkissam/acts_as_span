# frozen_string_literal: true

require 'active_model'

module ActsAsSpan
  # Validator that checks whether a record is overlapping with others
  #
  # Takes options `:instance_scope` (optional) and `:scope` (required):
  # * `instance_scope` is a proc or method name which, when evaluated by the record, returns
  #   a boolean value. When false, the validatior will not check for overlap.
  #   When true, the validator checks normally.
  # * `scope` is also a proc or method name. This must return a collection that
  #   determines which records' spans to compare.
  #
  # Usage:
  # Given a record with `siblings` defined, the most basic use case is:
  # ```
  # validates_with ActsAsSpan::NoOverlapValidator,
  #   scope: proc { siblings }
  # ```
  # When this record is validated, every record in the ActiveRecord relation
  #   `record.siblings` is checked for mutual overlap with `record`.
  #
  # Use `instance_scope` if there is some condition where a record oughtn't be
  #   validated for whatever reason:
  # ```
  # validates_with ActsAsSpan::NoOverlapValidator,
  #   scope: proc { siblings }, instance_scope: proc { favorite? }
  # ```
  # Now, when this record is validated, if `record.favorite?` is `true`,
  #   `record` must pass the overlap check with its siblings.
  #   If `record.favorite?` is `false`, it is under less scrutiny.
  #
  class NoOverlapValidator < ActiveModel::Validator
    def validate(record)
      return unless record.instance_eval(&instance_scope_lambda)

      overlapping_records = temporally_overlapping_for(record)

      return unless overlapping_records.any?

      error_message = options[:message] || :no_overlap
      record.errors.add(
        :base,
        error_message,
        model_name: record.class.model_name.human,
        model_name_plural: record.class.model_name.plural.humanize,
        start_date: record.span.start_date,
        end_date: record.span.end_date,
        count: overlapping_records.size,
        overlapping_records_s: overlapping_records.join(', ')
      )
    end

    # TODO: add back condition for start_date nil
    # TODO: add support for multiple spans (currently only checks :default)
    def temporally_overlapping_for(record)
      scope = record.instance_eval(&scope_lambda).to_a

      scope.filter { |other| record.span.overlap?(other.span) }
    end

    def scope_lambda
      @scope_lambda ||=
        case options[:scope]
        when Proc
          options[:scope]
        when String, Symbol
          method_name = options[:scope]
          proc { public_send(method_name) }
        else
          fail ArgumentError, 'Improper scope'
        end
    end

    def instance_scope_lambda
      @instance_scope_lambda ||=
        case options[:instance_scope]
        when String, Symbol
          method_name = options[:instance_scope]
          proc { public_send(method_name) }
        when Proc
          options[:instance_scope]
        else
          proc { true }
        end
    end
  end
end
