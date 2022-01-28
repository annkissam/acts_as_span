# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsSpan::SpanKlass::Superlatives do
  let(:span_klass) { ::SpanModel }

  let!(:today) { Date.current }

  let!(:earlier_record) do
    span_klass.create(
      start_date: earlier_start_date,
      end_date: earlier_end_date,
    )
  end
  let!(:later_record) do
    span_klass.create(
      start_date: later_start_date,
      end_date: later_end_date,
    )
  end

  let(:earlier_start_date) { today - 2.weeks }
  let(:earlier_end_date) { today + 1.week }

  let(:later_start_date) { today - 1.week }
  let(:later_end_date) { today + 2.weeks }

  shared_examples 'return later_record' do
    it 'returns the record with the latest start field' do
      expect(result).to eq(later_record)
    end
  end

  describe '.latest' do
    subject(:result) { span_klass.latest(**options) }

    context 'with no options' do
      let(:options) { {} }

      it_behaves_like 'return later_record'
    end

    context 'when called on a relation' do
      subject(:result) { span_klass.where.not(start_date: nil).latest }

      it_behaves_like 'return later_record'
    end

    describe ':by' do
      let(:options) { { by: by } }

      context 'when :start' do
        let(:by) { :start }

        it_behaves_like 'return later_record'
      end

      context 'when :end' do
        let(:by) { 'end_date' }

        it_behaves_like 'return later_record'
      end
    end
  end

  shared_examples 'return earlier_record' do
    it 'returns the record with the earliest start field' do
      expect(result).to eq(earlier_record)
    end
  end

  describe '.earliest' do
    subject(:result) { span_klass.earliest(**options) }

    context 'with no options' do
      let(:options) { {} }

      it_behaves_like 'return earlier_record'
    end

    context 'when called on a relation' do
      subject(:result) { span_klass.where.not(start_date: nil).earliest }

      it_behaves_like 'return earlier_record'
    end

    describe ':by' do
      let(:options) { { by: by } }

      context 'when :start' do
        let(:by) { :start_date }

        it_behaves_like 'return earlier_record'
      end

      context 'when :end' do
        let(:by) { :end }

        it_behaves_like 'return earlier_record'
      end
    end
  end
end
