# frozen_string_literal: true

require 'active_model'

module ActsAsSpan
  # Validator that checks whether a record is overlapping with others
  #
  # Takes options `:instance_scope` (optional) and `:scope` (required):
  # * `instance_scope` is a proc which, when evaluated by the record, returns
  #   a boolean value. When false, the validatior will not check for overlap.
  #   When true, the validator checks normally.
  # * `scope` is also a proc. This is must return an ActiveRecord Relation that
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
      overlapping_records = temporally_overlapping_for(record)
      instance_scope = if options[:instance_scope].is_a? Proc
                         record.instance_eval(&options[:instance_scope])
                       else
                         true
                       end

      return unless overlapping_records.any? && instance_scope

      record.errors.add(
        :base,
        :no_overlap,
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
      scope = record.instance_eval(&options[:scope])

      start_date = record.span.start_date || Date.current

      end_date = record.span.end_date
      end_field = record.span.end_field

      arel_table = record.class.arel_table

      if end_date
        scope.where(
          arel_table[record.span.start_field].lteq(end_date)
          .and(
            arel_table[end_field].gteq(start_date)
          .or(arel_table[end_field].eq(nil))
          )
        )
      else
        scope.where(
          arel_table[end_field].gteq(start_date)
          .or(arel_table[end_field].eq(nil))
        )
      end
    end
  end
end
