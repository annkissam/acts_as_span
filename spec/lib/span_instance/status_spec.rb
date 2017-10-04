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

  let(:span_model) { SpanModel.new(:start_date => Date.today, :end_date => nil) }
  let(:span) { span_model.span }

  context "#span_status & #span_status_to_s" do
    before(:each) do
      allow(span).to receive(:current?).and_return(false)
      allow(span).to receive(:future?).and_return(false)
      allow(span).to receive(:expired?).and_return(false)
    end

    it "should return :unknown when all_conditions == false" do
      expect(span.span_status).to eq(:unknown)
      expect(span.span_status_to_s).to eq('Unknown')
    end

    it "should return :current when current? == true" do
      expect(span).to receive(:current?).twice.and_return(true)

      expect(span.span_status).to eq(:current)
      expect(span.span_status_to_s).to eq('Current')
    end

    it "should return :current when future? == true" do
      expect(span).to receive(:future?).twice.and_return(true)

      expect(span.span_status).to eq(:future)
      expect(span.span_status_to_s).to eq('Future')
    end

    it "should return :current when expired? == true" do
      expect(span).to receive(:expired?).twice.and_return(true)

      expect(span.span_status).to eq(:expired)
      expect(span.span_status_to_s).to eq('Expired')
    end
  end
end
