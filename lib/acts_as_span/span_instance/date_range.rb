# frozen_string_literal: true

module ActsAsSpan
  class SpanInstance
    # Wraps two dates to create a range. If start date is null it is considered as a time infinitely far back.
    # If end date is null it is considered as a time infinitely in the future.
    class DateRange
      NEGATIVE_INFINITY = -(2**(0.size * 8 -2))
      INFINITY =(2**(0.size * 8 -2) -1)

      # @param start_date [Date]
      # @param end_date [Date]
      def initialize(start_date:, end_date:)
        start_date_value = numeric_value(start_date) || NEGATIVE_INFINITY
        end_date_value = numeric_value(end_date) || INFINITY

        fail ArgumentError if end_date_value < start_date_value

        @numerical_range = start_date_value..end_date_value
      end

      def overlap?(other)
        numerical_range.cover?(other.numerical_range.first) || numerical_range.cover?(other.numerical_range.last) ||
          other.numerical_range.cover?(numerical_range.first) || other.numerical_range.cover?(numerical_range.last)
      end

      protected

      attr_reader :numerical_range

      private

      def numeric_value(date)
        return unless date
        date.year * 10_000 + date.month * 100 + date.day
      end
    end

    private_constant :DateRange
  end
end
