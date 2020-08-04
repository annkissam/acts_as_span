# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsSpan::SpanKlass::Status do
  let(:span_klass) { ::SpanModel }

  let!(:today) { Date.current }

  describe '.current' do
    let!(:record) do
      span_klass.create(
        start_date: today - 1.week,
        end_date: today + 1.week,
      )
    end

    subject { span_klass.current(query_date) }

    context "when query_date is within the record's span" do
      let(:query_date) { record.start_date + 3.days }

      it { is_expected.not_to be_empty }
    end

    context "when query_date is before the record's span" do
      let(:query_date) { record.start_date - 1.week }

      it { is_expected.to be_empty }
    end

    context "when query_date is after the record's span" do
      let(:query_date) { record.end_date + 1.week }

      it { is_expected.to be_empty }
    end
  end
end
