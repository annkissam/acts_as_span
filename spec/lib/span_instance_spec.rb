require 'spec_helper'

#NOTE: we're also testing :start_date_field & :end_date_field options work

describe "Span" do
  before(:each) do
    build_model :span_model do
      date  :start_date_x
      date  :end_date_x
      
      acts_as_span :start_date_field => :start_date_x,
                   :end_date_field => :end_date_x
    end
  end
  
  context "#close!" do
    let(:span_model) { SpanModel.new(:start_date_x => Date.today, :end_date_x => nil) }
    let(:span) { span_model.span }
    
    it "should set end_date? to today" do
      lambda { span.close! }.should change(span_model, :end_date_x).from(nil).to(Date.today)
    end
    
    it "should set end_date? to the parameter" do
      lambda { span.close_on!(Date.today + 1.day) }.should change(span_model, :end_date_x).from(nil).to(Date.today + 1.day)
    end
  end
  
  context "start_date & end_date" do
    let(:span_model) { SpanModel.new(:start_date_x => Date.today, :end_date_x => Date.today + 1) }
    let(:span) { span_model.span }

    it "should return the start_date" do
      span.start_date.should == span_model.start_date_x
    end

    it "should return the end_date" do
      span.end_date.should == span_model.end_date_x
    end
  end
end