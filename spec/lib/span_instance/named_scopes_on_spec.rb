require 'spec_helper'

RSpec.describe "a basic model using acts_as_span" do
  before(:all) do
    @query_date = Date.current + 1.month
  end

  context "named_scopes and current_on?, expired_on?, and future_on?" do
    #    -2  -1   Q  +1  +2      C F E
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
    context "A) start_date < query_date & end_date < query_date" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date - 2.days, :end_date => @query_date - 1.day)
      end

      it "should NOT be included in #current" do
        expect(SpanModel.current_on(@query_date)).not_to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_truthy
      end
    end

    context "B) start_date < query_date & end_date == query_date" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date - 2.day, :end_date => @query_date)
      end

      it "should be included in #current" do
        expect(SpanModel.current_on(@query_date)).to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "C) start_date < query_date & end_date > query_date" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date - 2.day, :end_date => @query_date + 2.day)
      end

      it "should be included in #current" do
        expect(SpanModel.current_on(@query_date)).to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "D) start_date == query_date & end_date == query_date" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date, :end_date => @query_date)
      end

      it "should be included in #current" do
        expect(SpanModel.current_on(@query_date)).to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "E) start_date == query_date & end_date > query_date" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date, :end_date => @query_date + 2.day)
      end

      it "should be included in #current" do
        expect(SpanModel.current_on(@query_date)).to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "F) start_date > query_date & end_date > query_date" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date + 1.day, :end_date => @query_date + 2.days)
      end

      it "should NOT be included in #current" do
        expect(SpanModel.current_on(@query_date)).not_to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_falsey
      end

      it "should be included in #future" do
        expect(SpanModel.future_on(@query_date)).to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "G) start_date < query_date & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date - 2.day, :end_date => nil)
      end

      it "should be included in #current" do
        expect(SpanModel.current_on(@query_date)).to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "H) start_date == query_date & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date, :end_date => nil)
      end

      it "should be included in #current" do
        expect(SpanModel.current_on(@query_date)).to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "I) start_date > query_date & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date + 1.day, :end_date => nil)
      end

      it "should NOT be included in #current" do
        expect(SpanModel.current_on(@query_date)).not_to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_falsey
      end

      it "should be included in #future" do
        expect(SpanModel.future_on(@query_date)).to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "J) start_date == nil & end_date < query_date" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => @query_date - 1.day)
      end

      it "should NOT be included in #current" do
        expect(SpanModel.current_on(@query_date)).not_to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_truthy
      end
    end

    context "K) start_date == nil & end_date == query_date" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => @query_date)
      end

      it "should be included in #current" do
        expect(SpanModel.current_on(@query_date)).to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "L) start_date == nil & end_date > query_date" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => @query_date + 2.day)
      end

      it "should be included in #current" do
        expect(SpanModel.current_on(@query_date)).to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end

    context "M) start_date == nil & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => nil)
      end

      it "should be included in #current" do
        expect(SpanModel.current_on(@query_date)).to include(@span_model)
        expect(@span_model.current_on?(@query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(@query_date)).not_to include(@span_model)
        expect(@span_model.future_on?(@query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(@query_date)).not_to include(@span_model)
        expect(@span_model.expired_on?(@query_date)).to be_falsey
      end
    end
  end
end
