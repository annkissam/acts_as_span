require 'spec_helper'

describe "Span" do
  before(:each) do
    build_model :span_model do
      date  :start_date
      date  :end_date
    end
  end
  
  #let(:span_model) { SpanModel.new(:start_date => Date.today, :end_date => Date.today + 1) }
  #let(:span) { span_model.span }
  
  it "should be valid" do
    SpanModel.acts_as_span
    span_model = SpanModel.new(:start_date => nil, :end_date => nil)
    
    span_model.should be_valid
  end
  
  context ":start_date_field_required => true" do
    before do
      SpanModel.acts_as_span :start_date_field_required => true
    end
    
    it "should require a start_date" do
      span_model = SpanModel.new(:start_date => nil, :end_date => Date.today + 1)
      
      span_model.should_not be_valid
      span_model.errors[:start_date].should have(1).error
    end
  end
  
  context ":end_date_field_required => true" do
    before do
      SpanModel.acts_as_span :end_date_field_required => true
    end
    
    it "should require an end_date" do
      span_model = SpanModel.new(:start_date => Date.today, :end_date => nil)
      
      span_model.should_not be_valid
      span_model.errors[:end_date].should have(1).error
    end
  end
  
  it "should require a start_date before the end_date" do
    SpanModel.acts_as_span
    span_model = SpanModel.new(:start_date => Date.today, :end_date => Date.today - 1)
    
    span_model.should_not be_valid
    span_model.errors[:end_date].should have(1).error
  end
end
