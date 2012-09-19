require 'spec_helper'

describe "a basic model using acts_as_span" do
  before(:all) do 
    build_model :span_model do
      string   :description
      date     :start_date
      date     :end_date
      
      acts_as_span
    end
  end
  
  it "should not respond to start_date_string" do
    SpanModel.new.respond_to?(:start_date_string).should_not be_true
  end
  
  it "should not respond to end_string" do
    SpanModel.new.respond_to?(:end_date_string).should_not be_true
  end
  
  context "#close!" do
    it "should set end_date? to today" do
      @span_model = SpanModel.create
      lambda { @span_model.close! }.should change(@span_model, :end_date).from(nil).to(Date.today)
    end
    
    it "should set end_date? to the parameter" do
      @span_model = SpanModel.create
      lambda { @span_model.close!(Date.today + 1.day) }.should change(@span_model, :end_date).from(nil).to(Date.today + 1.day)
    end
  end
  
  context "#span_status & #span_status_to_s" do
    before(:each) do
      @span_model = SpanModel.new
      
      @span_model.stub!(:current?).and_return(false)
      @span_model.stub!(:future?).and_return(false)
      @span_model.stub!(:expired?).and_return(false)
    end
    
    it "should return :unknown when all_conditions == false" do
      @span_model.span_status.should == :unknown
      @span_model.span_status_to_s.should == 'Unknown'
    end
    
    it "should return :current when current? == true" do
      @span_model.should_receive(:current?).twice.and_return(true)
      @span_model.span_status.should == :current
      @span_model.span_status_to_s.should == 'Current'
    end
    
    it "should return :current when future? == true" do
      @span_model.should_receive(:future?).twice.and_return(true)
      @span_model.span_status.should == :future
      @span_model.span_status_to_s.should == 'Future'
    end
    
    it "should return :current when expired? == true" do
      @span_model.should_receive(:expired?).twice.and_return(true)
      @span_model.span_status.should == :expired
      @span_model.span_status_to_s.should == 'Expired'
    end
  end
end