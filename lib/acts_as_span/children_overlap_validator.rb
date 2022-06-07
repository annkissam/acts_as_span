# frozen_string_literal: true

module ActsAsSpan
  class ChildrenOverlapValidator < ActiveModel::Validator

    def validate(record)
      children = scope_lambda.call(record).find_all { |child| instance_scope_lambda.call(child) }

      overlappings = children.combination(2).find_all { |first, second| first.span.overlap?(second.span) }

      return if overlappings.empty?

      child_model_name = children.first.model_name

      record.errors.add(
        :base,
        error_message,
        model_name: record.class.model_name.human,
        child_model_name: child_model_name.human,
        child_model_name_plural: child_model_name.plural.humanize,
        count: overlappings.size,
      )
    end

    private

    def scope_lambda
      @scope_lambda ||=
        case options[:scope]
        when Proc
          options[:scope]
        when Symbol, String
          ->(record) { record.public_send(options[:scope]) }
        else
          fail ArgumentError, 'Invalid scope parameter'
        end
    end

    def instance_scope_lambda
      @instance_scope_lambda ||=
        case options[:instance_scope]
        when nil
          ->(_) { true }
        when Symbol, String
          ->(child) { child.public_send(options[:instance_scope]) }
        when Proc
          options[:instance_scope]
        end
    end

    def error_message
      @error_message ||= options.fetch(:message, :no_children_overlap)
    end
  end
end
