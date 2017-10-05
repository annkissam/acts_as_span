require 'spec_helper'

RSpec.describe "Span" do
  context "start_date & end_date" do
    let(:span_model) { SpanModel.new(:start_date => Date.today, :end_date => Date.today + 1) }
    let(:span) { span_model.span }

    it "should return the start_date" do
      expect(span.start_date).to eq(span_model.start_date)
    end

    it "should return the end_date" do
      expect(span.end_date).to eq(span_model.end_date)
    end
  end
end
