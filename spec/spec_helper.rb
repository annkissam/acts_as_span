require 'rubygems'
require 'acts_as_fu'
require 'spec'
require 'acts_as_span'

Spec::Runner.configure do |config|
  config.include ActsAsFu
end

describe 'it acts_as_span', :shared => true do
  it "should respond to acts_as_span with true" do
    described_class.acts_as_span?.should be_true
  end
end