require 'rubygems'
require 'bundler/setup'

#Automatically included in a rails application...
require 'active_support'

#Required for testing...
require 'acts_as_fu'

require 'acts_as_span'

RSpec.configure do |config|
  config.include ActsAsFu
end