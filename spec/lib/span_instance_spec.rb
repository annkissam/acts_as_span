require 'spec_helper'

RSpec.describe "Span" do
  context "start_date & end_date" do
    let(:span_model) { SpanModel.new(:start_date => Date.current, :end_date => Date.current + 1) }
    let(:span) { span_model.span }

    it "should return the start_date" do
      expect(span.start_date).to eq(span_model.start_date)
    end

    it "should return the end_date" do
      expect(span.end_date).to eq(span_model.end_date)
    end

    context "changed?" do
      it 'returns true when start_date has changed' do
        span_model.start_date = span_model.start_date + 5
        expect(span.start_date_changed?).to eq(true)
      end

      it 'returns true when end_date has changed' do
        span_model.end_date = span_model.end_date + 5
        expect(span.end_date_changed?).to eq(true)
      end
    end
  end
end
