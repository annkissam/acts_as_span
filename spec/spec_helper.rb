require 'rubygems'
require 'bundler/setup'
require 'acts_as_fu'

require 'acts_as_span'

RSpec.configure do |config|
  config.include ActsAsFu
end