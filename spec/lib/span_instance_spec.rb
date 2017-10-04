require 'spec_helper'

RSpec.describe "Span" do
  before(:all) do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table :span_models, force: true do |t|
        t.date :start_date
        t.date :end_date
      end
    end

    class SpanModel < ActiveRecord::Base
      acts_as_span :start_date_field => :start_date,
                   :end_date_field => :end_date
    end
  end

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
