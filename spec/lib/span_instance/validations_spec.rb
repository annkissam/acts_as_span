require 'spec_helper'

RSpec.describe "Span" do
  it "should be valid" do
    SpanModel.acts_as_span
    span_model = SpanModel.new(:start_date => nil, :end_date => nil)

    expect(span_model).to be_valid
  end

  it "should require a start_date before the end_date" do
    SpanModel.acts_as_span
    span_model = SpanModel.new(:start_date => Date.today, :end_date => Date.today - 1)

    expect(span_model).not_to be_valid
    expect(span_model.errors[:end_date].size).to eq(1)
  end
end
