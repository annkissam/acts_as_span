require 'spec_helper'

RSpec.describe "a basic model using acts_as_span" do
  context "named_scopes and current?, expired?, and future?" do
    #    -2  -1   T  +1  +2      C F E
    # A   |---|                      E
    # B   |-------|              C
    # C   |--------------|       C
    # D           |              C
    # E           |------|       C
    # F               |--|         F
    # G   |->                    C
    # H           |->            C
    # I               |->          F
    # J     <-|                      E
    # K         <-|              C
    # L                <-|       C
    # M           <->            C
    context "A) start_date < today & end_date < today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today - 2.days, :end_date => Date.today - 1.day)
      end

      it "should NOT be included in #current" do
        expect(SpanModel.current).not_to include(@span_model)
        expect(@span_model.current?).to be_falsey
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should be included in #expired" do
        expect(SpanModel.expired).to include(@span_model)
        expect(@span_model.expired?).to be_truthy
      end
    end

    context "B) start_date < today & end_date == today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today - 2.day, :end_date => Date.today)
      end

      it "should be included in #current" do
        expect(SpanModel.current).to include(@span_model)
        expect(@span_model.current?).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "C) start_date < today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today - 2.day, :end_date => Date.today + 2.day)
      end

      it "should be included in #current" do
        expect(SpanModel.current).to include(@span_model)
        expect(@span_model.current?).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "D) start_date == today & end_date == today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today, :end_date => Date.today)
      end

      it "should be included in #current" do
        expect(SpanModel.current).to include(@span_model)
        expect(@span_model.current?).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "E) start_date == today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today, :end_date => Date.today + 2.day)
      end

      it "should be included in #current" do
        expect(SpanModel.current).to include(@span_model)
        expect(@span_model.current?).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "F) start_date > today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today + 1.day, :end_date => Date.today + 2.days)
      end

      it "should NOT be included in #current" do
        expect(SpanModel.current).not_to include(@span_model)
        expect(@span_model.current?).to be_falsey
      end

      it "should be included in #future" do
        expect(SpanModel.future).to include(@span_model)
        expect(@span_model.future?).to be_truthy
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "G) start_date < today & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today - 2.day, :end_date => nil)
      end

      it "should be included in #current" do
        expect(SpanModel.current).to include(@span_model)
        expect(@span_model.current?).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "H) start_date == today & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today, :end_date => nil)
      end

      it "should be included in #current" do
        expect(SpanModel.current).to include(@span_model)
        expect(@span_model.current?).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "I) start_date > today & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today + 1.day, :end_date => nil)
      end

      it "should NOT be included in #current" do
        expect(SpanModel.current).not_to include(@span_model)
        expect(@span_model.current?).to be_falsey
      end

      it "should be included in #future" do
        expect(SpanModel.future).to include(@span_model)
        expect(@span_model.future?).to be_truthy
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "J) start_date == nil & end_date < today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => Date.today - 1.day)
      end

      it "should NOT be included in #current" do
        expect(SpanModel.current).not_to include(@span_model)
        expect(@span_model.current?).to be_falsey
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should be included in #expired" do
        expect(SpanModel.expired).to include(@span_model)
        expect(@span_model.expired?).to be_truthy
      end
    end

    context "K) start_date == nil & end_date == today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => Date.today)
      end

      it "should be included in #current" do
        expect(SpanModel.current).to include(@span_model)
        expect(@span_model.current?).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "L) start_date == nil & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => Date.today + 2.day)
      end

      it "should be included in #current" do
        expect(SpanModel.current).to include(@span_model)
        expect(@span_model.current?).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end

    context "M) start_date == nil & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => nil)
      end

      it "should be included in #current" do
        expect(SpanModel.current).to include(@span_model)
        expect(@span_model.current?).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future).not_to include(@span_model)
        expect(@span_model.future?).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired).not_to include(@span_model)
        expect(@span_model.expired?).to be_falsey
      end
    end
  end
end
