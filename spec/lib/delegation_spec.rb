# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Span' do
  let(:span_model) { SpanModel.new(start_date: Date.current, end_date: nil) }
  let(:span_klass) { SpanModel.span }
  let(:span_instance) { span_model.span }

  describe 'ClassMethods' do
    it 'delegates .earliest' do
      expect(span_klass).to receive(:earliest).and_return(true)

      SpanModel.earliest
    end

    it 'delegates .latest' do
      expect(span_klass).to receive(:earliest).and_return(true)

      SpanModel.earliest
    end

    it 'should delegate current' do
      expect(span_klass).to receive(:current).and_return(true)

      SpanModel.current
    end

    it 'should delegate current_on' do
      expect(span_klass).to receive(:current_on).and_return(true)

      SpanModel.current_on
    end

    it 'should delegate future' do
      expect(span_klass).to receive(:future).and_return(true)

      SpanModel.future
    end

    it 'should delegate future_on' do
      expect(span_klass).to receive(:future_on).and_return(true)

      SpanModel.future_on
    end

    it 'should delegate expired' do
      expect(span_klass).to receive(:expired).and_return(true)

      SpanModel.expired
    end

    it 'should delegate expired_on' do
      expect(span_klass).to receive(:expired_on).and_return(true)

      SpanModel.expired_on
    end
  end

  describe 'InstanceMethods' do
    it 'should delegate span_status' do
      expect(span_instance).to receive(:span_status).and_return(true)

      span_model.span_status
    end

    it 'should delegate span_status_on' do
      expect(span_instance).to receive(:span_status_on).and_return(true)

      span_model.span_status_on
    end

    it 'should delegate current?' do
      expect(span_instance).to receive(:current?).and_return(true)

      span_model.current?
    end

    it 'should delegate current_on?' do
      expect(span_instance).to receive(:current_on?).and_return(true)

      span_model.current_on?
    end

    it 'should delegate future?' do
      expect(span_instance).to receive(:future?).and_return(true)

      span_model.future?
    end

    it 'should delegate future_on?' do
      expect(span_instance).to receive(:future_on?).and_return(true)

      span_model.future_on?
    end

    it 'should delegate expired?' do
      expect(span_instance).to receive(:expired?).and_return(true)

      span_model.expired?
    end

    it 'should delegate expired_on?' do
      expect(span_instance).to receive(:expired_on?).and_return(true)

      span_model.expired_on?
    end
  end
end
