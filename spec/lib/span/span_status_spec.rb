require 'spec_helper'

describe "Span" do
  before(:each) do
    build_model :span_model do
      date  :start_date
      date  :end_date
      
      acts_as_span
    end
  end
  
  let(:span_model) { SpanModel.new(:start_date => Date.today, :end_date => nil) }
  let(:span) { span_model.span }
  
  context "#span_status & #span_status_to_s" do
    before(:each) do
      span.stub!(:current?).and_return(false)
      span.stub!(:future?).and_return(false)
      span.stub!(:expired?).and_return(false)
    end
    
    it "should return :unknown when all_conditions == false" do
      span.span_status.should == :unknown
      span.span_status_to_s.should == 'Unknown'
    end
    
    it "should return :current when current? == true" do
      span.should_receive(:current?).twice.and_return(true)
      
      span.span_status.should == :current
      span.span_status_to_s.should == 'Current'
    end
    
    it "should return :current when future? == true" do
      span.should_receive(:future?).twice.and_return(true)
      
      span.span_status.should == :future
      span.span_status_to_s.should == 'Future'
    end
    
    it "should return :current when expired? == true" do
      span.should_receive(:expired?).twice.and_return(true)
      
      span.span_status.should == :expired
      span.span_status_to_s.should == 'Expired'
    end
  end
  
  context "#close!" do
    it "should set end_date? to today" do
      lambda { span.close! }.should change(span_model, :end_date).from(nil).to(Date.today)
    end
    
    it "should set end_date? to the parameter" do
      lambda { span.close_on!(Date.today + 1.day) }.should change(span_model, :end_date).from(nil).to(Date.today + 1.day)
    end
  end
end