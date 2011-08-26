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
  
  it "should delegate close!" do
    span.should_receive(:close!).and_return(true)
    
    span_model.close!
  end
  
  it "should delegate close_on!" do
    span.should_receive(:close_on!).and_return(true)
    
    span_model.close_on!
  end
  
  it "should delegate span_status" do
    span.should_receive(:span_status).and_return(true)
    
    span_model.span_status
  end
  
  it "should delegate span_status_on" do
    span.should_receive(:span_status_on).and_return(true)
    
    span_model.span_status_on
  end
  
  it "should delegate span_status_to_s" do
    span.should_receive(:span_status_to_s).and_return(true)
    
    span_model.span_status_to_s
  end
  
  it "should delegate span_status_to_s_on" do
    span.should_receive(:span_status_to_s_on).and_return(true)
    
    span_model.span_status_to_s_on
  end
end