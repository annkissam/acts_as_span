require 'spec_helper'

RSpec.describe "a basic model using acts_as_span" do
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
    let(:span_a) {[ - 2.days, - 1.day  ]}
    let(:span_b) {[ - 2.days,   0.days ]}
    let(:span_c) {[ - 2.days,   2.days ]}
    let(:span_d) {[   0.days,   0.days ]}
    let(:span_e) {[   0.days,   2.days ]}
    let(:span_f) {[   1.day,    2.days ]}
    let(:span_g) {[ - 2.days, nil      ]}
    let(:span_h) {[   0.days, nil      ]}
    let(:span_i) {[   1.day,  nil      ]}
    let(:span_j) {[ nil,      - 1.day  ]}
    let(:span_k) {[ nil,        0.days ]}
    let(:span_l) {[ nil,        2.days ]}
    let(:span_m) {[ nil,      nil      ]}

    let(:query_date) { Date.current + (-24..24).to_a.sample.month }

    let!(:span_model) do
      current_start_date = start_date.nil? ? nil : query_date + start_date
      current_end_date = end_date.nil? ? nil : query_date + end_date

      SpanModel.create!(
        start_date: current_start_date,
        end_date: current_end_date)
    end

    context "A) start_date < query_date & end_date < query_date" do
      let(:start_date) { span_a[0] }
      let(:end_date) { span_a[1] }

      it "should NOT be included in #current" do
        expect(SpanModel.current_on(query_date)).not_to include(span_model)
        expect(span_model.current_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should be included in #expired" do
        expect(SpanModel.expired_on(query_date)).to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_truthy
      end
    end

    context "B) start_date < query_date & end_date == query_date" do
      let(:start_date) { span_b[0] }
      let(:end_date) { span_b[1] }

      it "should be included in #current" do
        expect(SpanModel.current_on(query_date)).to include(span_model)
        expect(span_model.current_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "C) start_date < query_date & end_date > query_date" do
      let(:start_date) { span_c[0] }
      let(:end_date) { span_c[1] }

      it "should be included in #current" do
        expect(SpanModel.current_on(query_date)).to include(span_model)
        expect(span_model.current_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "D) start_date == query_date & end_date == query_date" do
      let(:start_date) { span_d[0] }
      let(:end_date) { span_d[1] }

      it "should be included in #current" do
        expect(SpanModel.current_on(query_date)).to include(span_model)
        expect(span_model.current_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "E) start_date == query_date & end_date > query_date" do
      let(:start_date) { span_e[0] }
      let(:end_date) { span_e[1] }

      it "should be included in #current" do
        expect(SpanModel.current_on(query_date)).to include(span_model)
        expect(span_model.current_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "F) start_date > query_date & end_date > query_date" do
      let(:start_date) { span_f[0] }
      let(:end_date) { span_f[1] }

      it "should NOT be included in #current" do
        expect(SpanModel.current_on(query_date)).not_to include(span_model)
        expect(span_model.current_on?(query_date)).to be_falsey
      end

      it "should be included in #future" do
        expect(SpanModel.future_on(query_date)).to include(span_model)
        expect(span_model.future_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "G) start_date < query_date & end_date == nil" do
      let(:start_date) { span_g[0] }
      let(:end_date) { span_g[1] }

      it "should be included in #current" do
        expect(SpanModel.current_on(query_date)).to include(span_model)
        expect(span_model.current_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "H) start_date == query_date & end_date == nil" do
      let(:start_date) { span_h[0] }
      let(:end_date) { span_h[1] }

      it "should be included in #current" do
        expect(SpanModel.current_on(query_date)).to include(span_model)
        expect(span_model.current_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "I) start_date > query_date & end_date == nil" do
      let(:start_date) { span_i[0] }
      let(:end_date) { span_i[1] }

      it "should NOT be included in #current" do
        expect(SpanModel.current_on(query_date)).not_to include(span_model)
        expect(span_model.current_on?(query_date)).to be_falsey
      end

      it "should be included in #future" do
        expect(SpanModel.future_on(query_date)).to include(span_model)
        expect(span_model.future_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "J) start_date == nil & end_date < query_date" do
      let(:start_date) { span_j[0] }
      let(:end_date) { span_j[1] }

      it "should NOT be included in #current" do
        expect(SpanModel.current_on(query_date)).not_to include(span_model)
        expect(span_model.current_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should be included in #expired" do
        expect(SpanModel.expired_on(query_date)).to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_truthy
      end
    end

    context "K) start_date == nil & end_date == query_date" do
      let(:start_date) { span_k[0] }
      let(:end_date) { span_k[1] }

      it "should be included in #current" do
        expect(SpanModel.current_on(query_date)).to include(span_model)
        expect(span_model.current_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "L) start_date == nil & end_date > query_date" do
      let(:start_date) { span_l[0] }
      let(:end_date) { span_l[1] }

      it "should be included in #current" do
        expect(SpanModel.current_on(query_date)).to include(span_model)
        expect(span_model.current_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end

    context "M) start_date == nil & end_date == nil" do
      let(:start_date) { span_m[0] }
      let(:end_date) { span_m[1] }

      it "should be included in #current" do
        expect(SpanModel.current_on(query_date)).to include(span_model)
        expect(span_model.current_on?(query_date)).to be_truthy
      end

      it "should NOT be included in #future" do
        expect(SpanModel.future_on(query_date)).not_to include(span_model)
        expect(span_model.future_on?(query_date)).to be_falsey
      end

      it "should NOT be included in #expired" do
        expect(SpanModel.expired_on(query_date)).not_to include(span_model)
        expect(span_model.expired_on?(query_date)).to be_falsey
      end
    end
  end
end
