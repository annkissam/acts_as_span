require 'spec_helper'

RSpec.describe "Span" do
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

  #let(:span_model) { SpanModel.new(:start_date => Date.today, :end_date => Date.today + 1) }
  #let(:span) { span_model.span }

  it "should be valid" do
    SpanModel.acts_as_span
    span_model = SpanModel.new(:start_date => nil, :end_date => nil)

    expect(span_model).to be_valid
  end

  context ":start_date_field_required => true" do
    before do
      SpanModel.acts_as_span :start_date_field_required => true
    end

    it "should require a start_date" do
      span_model = SpanModel.new(:start_date => nil, :end_date => Date.today + 1)

      expect(span_model).not_to be_valid
      expect(span_model.errors[:start_date].size).to eq(1)
    end
  end

  context ":end_date_field_required => true" do
    before do
      SpanModel.acts_as_span :end_date_field_required => true
    end

    it "should require an end_date" do
     span_model = SpanModel.new(:start_date => Date.today, :end_date => nil)

      expect(span_model).not_to be_valid
      expect(span_model.errors[:end_date].size).to eq(1)
    end
  end

  it "should require a start_date before the end_date" do
    SpanModel.acts_as_span
    span_model = SpanModel.new(:start_date => Date.today, :end_date => Date.today - 1)

    expect(span_model).not_to be_valid
    expect(span_model.errors[:end_date].size).to eq(1)
  end
end
