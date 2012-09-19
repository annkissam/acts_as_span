require 'spec_helper'

describe "#acts_as_span?" do
  before(:all) do 
    build_model :negative_model do
      date  :start_date
      date  :end_date
    end
    
    build_model :positive_model do
      date  :start_date
      date  :end_date
      
      acts_as_span
    end
  end
  
  context "NegativeModel" do
    it "should return false (Class)" do
      NegativeModel.acts_as_span?.should be_false
    end
    
    it "should return false (Instance)" do
      NegativeModel.new.acts_as_span?.should be_false
    end
  end
  
  context "PositiveModel" do
    it "should return true (Class)" do
      PositiveModel.acts_as_span?.should be_true
    end
  
    it "should return true (Instance)" do
      PositiveModel.new.acts_as_span?.should be_true
    end
  end
end