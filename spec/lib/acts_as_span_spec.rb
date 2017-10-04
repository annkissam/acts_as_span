require 'spec_helper'

RSpec.describe "acts_as_span" do
  before do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table :span_models, force: true do |t|
        t.date :start_date
        t.date :end_date
      end
    end

    class SpanModel < ActiveRecord::Base
      acts_as_span
    end
  end

  context "ClassMethods" do
    it "should have 1 acts_as_span_definition" do
      expect(SpanModel.acts_as_span_definitions.size).to eq(1)
    end

    it "should set default options for acts_as_span_definition" do
      span_definition = SpanModel.acts_as_span_definitions[:default]

      expect(span_definition.start_field).to eq(:start_date)
      expect(span_definition.end_field).to eq(:end_date)
      expect(span_definition.start_field_required).to be_falsey
      expect(span_definition.end_field_required).to be_falsey
      expect(span_definition.exclude_end).to be_falsey
      expect(span_definition.span_overlap_scope).to be_nil
      expect(span_definition.span_overlap_count).to be_nil
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
