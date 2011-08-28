require 'spec_helper'

describe "acts_as_span" do
  before(:each) do
    build_model :negative_model do
    end
  end
    
  context "NegativeModel (Class)" do
    it "should respond_to acts_as_span" do
      NegativeModel.should respond_to(:acts_as_span)
    end
    
    it "should return false for acts_as_span?" do
      NegativeModel.acts_as_span?.should be_false
    end
    
    it "should have no acts_as_span_definitions" do
      NegativeModel.acts_as_span_definitions.should be_empty
    end
  end
  
  context "NegativeModel (Instance)" do
    let(:negative_model) { NegativeModel.new }
    
    it "should return false for acts_as_span?" do
      negative_model.acts_as_span?.should be_false
    end
  end
end