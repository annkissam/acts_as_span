require 'spec_helper'

RSpec.describe "Span" do
  before(:each) do
    build_model :span_model do
      date  :start_date
      date  :end_date

      acts_as_span
    end
  end

  let(:span_model) { SpanModel.new(:start_date => Date.today, :end_date => nil) }
  let(:span_klass) { SpanModel.span }
  let(:span_instance) { span_model.span }

  context "ClassMethods" do
    it "should delegate current" do
      span_klass.should_receive(:current).and_return(true)

      SpanModel.current
    end

    it "should delegate current_on" do
      span_klass.should_receive(:current_on).and_return(true)

      SpanModel.current_on
    end

    it "should delegate future" do
      span_klass.should_receive(:future).and_return(true)

      SpanModel.future
    end

    it "should delegate future_on" do
      span_klass.should_receive(:future_on).and_return(true)

      SpanModel.future_on
    end

    it "should delegate expired" do
      span_klass.should_receive(:expired).and_return(true)

      SpanModel.expired
    end

    it "should delegate expired_on" do
      span_klass.should_receive(:expired_on).and_return(true)

      SpanModel.expired_on
    end
  end

  context "InstanceMethods" do
    it "should delegate close!" do
      span_instance.should_receive(:close!).and_return(true)

      span_model.close!
    end

    it "should delegate close_on!" do
      span_instance.should_receive(:close_on!).and_return(true)

      span_model.close_on!
    end

    it "should delegate span_status" do
      span_instance.should_receive(:span_status).and_return(true)

      span_model.span_status
    end

    it "should delegate span_status_on" do
      span_instance.should_receive(:span_status_on).and_return(true)

      span_model.span_status_on
    end

    it "should delegate span_status_to_s" do
      span_instance.should_receive(:span_status_to_s).and_return(true)

      span_model.span_status_to_s
    end

    it "should delegate span_status_to_s_on" do
      span_instance.should_receive(:span_status_to_s_on).and_return(true)

      span_model.span_status_to_s_on
    end

    it "should delegate current?" do
      span_instance.should_receive(:current?).and_return(true)

      span_model.current?
    end

    it "should delegate current_on?" do
      span_instance.should_receive(:current_on?).and_return(true)

      span_model.current_on?
    end

    it "should delegate future?" do
      span_instance.should_receive(:future?).and_return(true)

      span_model.future?
    end

    it "should delegate future_on?" do
      span_instance.should_receive(:future_on?).and_return(true)

      span_model.future_on?
    end

    it "should delegate expired?" do
      span_instance.should_receive(:expired?).and_return(true)

      span_model.expired?
    end

    it "should delegate expired_on?" do
      span_instance.should_receive(:expired_on?).and_return(true)

      span_model.expired_on?
    end
  end
end
