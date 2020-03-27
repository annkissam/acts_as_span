require 'bundler/setup'
require 'acts_as_span'
require 'pry'

require 'active_record'
require 'active_support'
require 'spec_models'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Enable the pattern
  # expect{ event }.to not_change(x).and not_change(y)...
  # for checking if one event does NOT change several objects
  RSpec::Matchers.define_negated_matcher(:not_change, :change)

  config.after do
    Temping.cleanup
  end
end
