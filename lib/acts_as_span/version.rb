# frozen_string_literal: true

module ActsAsSpan
  module VERSION
    MAJOR = 1
    MINOR = 2
    TINY  = 2
    PRE   = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    SUMMARY = "acts_as_span #{STRING}"
  end
end
