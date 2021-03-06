require 'spec_helper'

RSpec.describe "acts_as_span" do
  it 'raises an ArgumentError when unsupported arguments are passed' do
    expect do
      SpannableModel.acts_as_span(
        start_field: :starting_date,
        end_field: :ending_date,
        span_overlap_scope: [:unique_by_date_range]
      )
    end.to raise_error(
      ArgumentError, "Unsupported option(s): 'span_overlap_scope'"
    )
  end

  it "doesn't raise an ArgumentError when valid arguments are passed" do
    expect do
      SpannableModel.acts_as_span(
        start_field: :starting_date,
        end_field: :ending_date
      )
    end.not_to raise_error
  end

  context "ClassMethods" do
    it "should have 1 acts_as_span_definition" do
      expect(SpanModel.acts_as_span_definitions.size).to eq(1)
    end

    it "should set default options for acts_as_span_definition" do
      span_definition = SpanModel.acts_as_span_definitions[:default]

      expect(span_definition.start_field).to eq(:start_date)
      expect(span_definition.end_field).to eq(:end_date)
      expect(span_definition.exclude_end).to be_falsey
      expect(span_definition.name).to eq(:default)
    end

    it "should return a SpanKlass w/ span" do
      expect(SpanModel.span).to be_instance_of(ActsAsSpan::SpanKlass)
    end

    it "should return a SpanKlass w/ span_for(:default)" do
      expect(SpanModel.span_for(:default)).to be_instance_of(ActsAsSpan::SpanKlass)
    end

    it "should have (1) spans" do
      expect(SpanModel.spans.size).to eq(1)
    end
  end

  context "InstanceMethods" do
    let(:span_model) { SpanModel.new }

    it "should return a SpanInstance w/ span" do
      expect(span_model.span).to be_instance_of(ActsAsSpan::SpanInstance)
    end

    it "should return a SpanInstance w/ span_for(:default)" do
      expect(span_model.span_for(:default)).to be_instance_of(ActsAsSpan::SpanInstance)
    end

    it "should have (1) spans" do
      expect(span_model.spans.size).to eq(1)
    end
  end
end
