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

  describe '#overlap?' do
    def overlaps?(start_date1, end_date1, start_date2, end_date2)
      span1 = SpanModel.new(start_date: start_date1, end_date: end_date1).span
      span2 = SpanModel.new(start_date: start_date2, end_date: end_date2).span
      span1.overlap?(span2)
    end

    it 'properly detects overlappings' do
      expect(overlaps?(Date.new(2022, 1, 1), Date.new(2022, 2, 1), Date.new(2022, 2, 2), Date.new(2022, 3, 1))).to be_falsey
      expect(overlaps?(Date.new(2022, 1, 1), Date.new(2022, 2, 1), Date.new(2022, 2, 2), nil)).to be_falsey
      expect(overlaps?(nil, Date.new(2022, 2, 1), Date.new(2022, 2, 2), Date.new(2022, 3, 1))).to be_falsey
      expect(overlaps?(Date.new(2022, 1, 1), Date.new(2022, 2, 1), Date.new(2022, 2, 1), Date.new(2022, 3, 1))).to be_truthy
      expect(overlaps?(Date.new(2022, 1, 1), nil, Date.new(2022, 2, 1), Date.new(2022, 3, 1))).to be_truthy
      expect(overlaps?(Date.new(2022, 1, 1), Date.new(2022, 2, 1), Date.new(2022, 1, 20), Date.new(2022, 3, 1))).to be_truthy
      expect(overlaps?(Date.new(2022, 1, 30), Date.new(2022, 4, 1), Date.new(2022, 1, 20), Date.new(2022, 1, 30))).to be_truthy
      expect(overlaps?(Date.new(2022, 2, 1), Date.new(2022, 4, 1), Date.new(2022, 1, 20), Date.new(2022, 1, 30))).to be_falsey
      expect(overlaps?(Date.new(2022, 2, 1), nil, Date.new(2022, 1, 20), Date.new(2022, 1, 30))).to be_falsey
    end
  end
end
