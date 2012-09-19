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

=begin
describe "an active_record class calls has_ein with no parameters" do
  before(:all) do 
    build_model :has_ein_model do
      string  :ein
      has_ein
    end
  end
  
  it "should respond to has_ein? with true" do
    HasEinModel.has_ein?.should be_true
  end
  
  it "should default has_ein to :ein"  do
    HasEinModel.should have(1).has_ein?
    HasEinModel.has_ein?[0].should == :ein
  end
  
  it "should remove dashes and spaces" do
    @model = HasEinModel.new(:ein => '00-000 00 00')
    #Dashes and spaces are removed before_validation
    @model.valid?
    @model.ein.should == '000000000'
  end
  
  it "should be valid with 9 digits" do
    @model = HasEinModel.new(:ein => '00-0000000')
    @model.should be_valid
  end
  
  it "should be invalid with anything but 9 digits" do
    @model = HasEinModel.new(:ein => '00-000000')
    @model.should_not be_valid
    
    @model = HasEinModel.new(:ein => '00-00000000')
    @model.should_not be_valid
  end
  
  it "should format a valid ein" do
    @model = HasEinModel.new(:ein => '00-0000000')
    @model.valid?
    @model.formatted_ein.should == '00-0000000'
  end
  
  it "should respond with N/A when there's no EIN" do
    @model = HasEinModel.new
    @model.formatted_ein.should == 'N/A'
  end
end
=end