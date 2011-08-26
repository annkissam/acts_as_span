require 'spec_helper'

describe "acts_as_span" do
  before(:each) do
    build_model :span_model do
      acts_as_span
    end
  end
  
  context "SpanModel (Class)" do
    it "should return true for acts_as_span?" do
      SpanModel.acts_as_span?.should be_true
    end
    
    it "should have 1 acts_as_span_definition" do
      SpanModel.should have(1).acts_as_span_definitions
    end
    
    it "should set default options for acts_as_span_definition" do
      span_definition = SpanModel.acts_as_span_definitions[:default]
      
      span_definition.start_date_field.should == :start_date
      span_definition.end_date_field.should == :end_date
      span_definition.start_date_field_required.should be_false
      span_definition.end_date_field_required.should be_false
      span_definition.exclude_end.should be_false
      span_definition.span_overlap_scope.should be_nil
      span_definition.span_overlap_count.should be_nil
      span_definition.name.should == :default
    end
  end
  
  context "SpanModel (Instance)" do
    let(:span_model) { SpanModel.new }
    
    it "should return true for acts_as_span?" do
      span_model.acts_as_span?.should be_true
    end
    
    #it "should have 1 acts_as_span_instance" do
    #  span_model.should have(1).acts_as_span_instances
    #end

    it "should return a Span w/ span" do
      span_model.span.should be_instance_of(ActsAsSpan::Span)
    end

    it "should return a Span w/ span_for(:default)" do
      span_model.span_for(:default).should be_instance_of(ActsAsSpan::Span)
    end
    
    it "should have (1) spans" do
      span_model.spans.should have(1).span
    end
    
    #NOTE: This is (indirectly) tested in span/validate_span
    #it "should validate_spans" do
    #end
  end
end
