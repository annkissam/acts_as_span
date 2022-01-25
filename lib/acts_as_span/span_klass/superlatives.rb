# frozen_string_literal: true

require 'active_support'
require 'active_record'

module ActsAsSpan
  class SpanKlass
    # Defines span superlatives (e.g. "latest" or "earliest") for use on
    #   collections of records that act as span
    module Superlatives
      extend ActiveSupport::Concern

      included do
        def method_symbols
          METHOD_SYMBOLS
        end

        # Retrieves the earliest record in a collection of spanned records.
        # Note: Calls '.order' on the class
        #
        # Options:
        # * :by (default: :start)
        #   A symbol from [:start, :start_date, :end, :end_date]
        #   The end of the span to sort by. If set to `:start` or `:start_date`,
        #     finds the record with the earliest value in the start date.
        #     If set to `:end` or `:end_date`, finds the record with the
        #     earliest end date.
        # * :additional_order (default: {})
        #   A Hash that provides additional sorting. If one of the span fields
        #     are included in this argument, this method will _not_ overwrite
        #     the original order for that field.
        #   The Hash is of the form { field_name: :asc, field_name_2: :desc }
        #
        # Example:
        #   collection.latest(by: :end, order: { id: :desc, name: :asc })
        def earliest(by: :start)
          field = field_from_option(by)

          klass.order(field => :asc).first
        end

        # Retrieves the earliest record in a collection of spanned records.
        # Note: Calls '.reorder' on the class
        #
        # Options:
        # * :by (default: :start)
        #   A symbol from [:start, :start_date, :end, :end_date]
        #   The end of the span to sort by. If set to `:start` or `:start_date`,
        #     finds the record with the earliest value in the start date.
        #     If set to `:end` or `:end_date`, finds the record with the
        #     earliest end date.
        # * :additional_order (default: {})
        #   A Hash that provides additional sorting. If one of the span fields
        #     are included in this argument, this method will _not_ overwrite
        #     the original order for that field.
        #   The Hash is of the form { field_name: :asc, field_name_2: :desc }
        #
        # Example:
        #   collection.latest(by: :end, order: { id: :desc, name: :asc })
        def earliest!(by: :start)
          field = field_from_option(by)

          klass.reorder(field => :asc).first
        end

        # Retrieves the latest record in a collection of spanned records.
        # Note: Calls '.reorder' on the class, removing existing orders in the
        #   collection.
        #
        # Options:
        # * :by (default: :start)
        #   A symbol from [:start, :start_date, :end, :end_date]
        #   The end of the span to sort by. If set to `:start` or `:start_date`,
        #     finds the record with the latest value in the start date.
        #     If set to `:end` or `:end_date`, finds the record with the
        #     latest end date.
        # * :additional_order (default: {})
        #   A Hash that provides additional sorting. If one of the span fields
        #     are included in this argument, this method will _not_ overwrite
        #     the original order for that field.
        #   The Hash is of the form { field_name: :asc, field_name_2: :desc }
        #
        # Example:
        #   collection.latest(by: :end, order: { created_at: :asc })
        def latest(by: :start)
          field = field_from_option(by)

          klass.order(field => :desc).first
        end

        # Retrieves the latest record in a collection of spanned records.
        # Note: Calls '.reorder' on the class, removing existing orders in the
        #   collection.
        #
        # Options:
        # * :by (default: :start)
        #   A symbol from [:start, :start_date, :end, :end_date]
        #   The end of the span to sort by. If set to `:start` or `:start_date`,
        #     finds the record with the latest value in the start date.
        #     If set to `:end` or `:end_date`, finds the record with the
        #     latest end date.
        # * :additional_order (default: {})
        #   A Hash that provides additional sorting. If one of the span fields
        #     are included in this argument, this method will _not_ overwrite
        #     the original order for that field.
        #   The Hash is of the form { field_name: :asc, field_name_2: :desc }
        #
        # Example:
        #   collection.latest(by: :end, order: { created_at: :asc })
        def latest!(by: :start)
          field = field_from_option(by)

          klass.reorder(field => :desc).first
        end

        private

        # Take things like "start" or "start_date" and turn them into suitable
        #   field symbols.
        #
        # Examples:
        #   field_from_option(:start)       # => :start
        #   field_from_option('start_date') # => :start
        #   field_from_option(:strat)       # raises ArgumentError
        def field_from_option(option)
          option = option&.to_sym

          if %i[start start_date].include? option
            start_field
          elsif %i[end end_date].include? option
            end_field
          else
            raise ArgumentError, "Unknown option: #{option}"
          end
        end
      end

      METHOD_SYMBOLS = %i[earliest latest].freeze
    end
  end
end
