# frozen_string_literal: true

module ActsAsSpan
  module VERSION
    MAJOR = 2
    MINOR = 0
    TINY  = 0
    PRE   = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    SUMMARY = "acts_as_span #{STRING}"
  end
end
