require 'spec_helper'

RSpec.describe "a basic model using acts_as_span", skip: true do
  let(:span_a) {[ - 4.days, - 3.day  ]}
  let(:span_b) {[ - 4.days,   1.days ]}
  let(:span_c) {[ - 4.days,   4.days ]}
  let(:span_d) {[ - 1.day,    1.day ]}
  let(:span_e) {[ - 1.days,   4.days ]}
  let(:span_f) {[   3.days,   4.days ]}
  let(:span_g) {[ - 4.days, nil      ]}
  let(:span_h) {[ - 1.days, nil      ]}
  let(:span_i) {[   3.days, nil      ]}
  let(:span_j) {[ nil,        4.days ]}
  let(:span_k) {[ nil,        1.day  ]}
  let(:span_l) {[ nil,       -3.days ]}
  let(:span_m) {[ nil,      nil      ]}

  let(:query_date) { Date.current }

  let!(:scoped_model_model) do
    current_start_date = start_date.nil? ? nil : query_date + start_date
    current_end_date = end_date.nil? ? nil : query_date + end_date

    SpanModel.create!(
      start_date: current_start_date,
      end_date: current_end_date)
  end

  let!(:span_model) do
    SpanModel.create!(
      start_date: query_date + span[:start],
      end_date: query_date + span[:end])
  end

  context "span_overlap_count == 0" do
    #    -4  -3  -2  -1  +1  +2  +3  +4
    #             |-----------|           TEST SPAN
    # A   |---|                           VALID
    # B   |---------------|
    # C   |---------------------------|
    # D               |---|
    # E               |---------------|
    # F                           |---|   VALID
    # G   |->
    # H               |->
    # I                           |->     VALID
    # J                             <-|
    # K                 <-|
    # L     <-|                           VALID
    # M               <--->


    context "span_model.start_date && span_model.end_date" do
      let(:span) {{ start: -2.days, end: +2.days }}

      context "A) start_date < span_model.start_date && end_date < span_model.start_date" do
        # let(:start_date) {
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today - 3.days)
          scoped_model.should be_valid
          scoped_model.overlap?(span_model).should be_false
        end
      end

      context "B) start_date < span_model.start_date && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "C) start_date < span_model.start_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "D) start_date IN span && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "E) start_date IN span && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 4.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "F) start_date > span_model.end_date && end_date > span_model.end_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => Date.today + 4.days)
          scoped_model.should be_valid
          scoped_model.overlap?(span_model).should be_false
        end
      end

      context "G) start_date < span_model.start_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "H) start_date IN span && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "I) start_date > span_model.end_date && end_date nil" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => nil)
          scoped_model.should be_valid
          scoped_model.overlap?(span_model).should be_false
        end
      end

      context "J) start_date nil && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "K) start_date nil && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "L) start_date nil && end_date < span_model.start_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today - 3.days)
          scoped_model.should be_valid
          scoped_model.overlap?(span_model).should be_false
        end
      end

      context "M) start_date nil && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end
    end

    #    -4  -3  -2  -1  +1  +2  +3  +4
    #             |------------------->   TEST SPAN
    # A   |---|                           VALID
    # B   |---------------|
    # C   |---------------------------|
    # D               |---|
    # E               |---------------|
    # F                           |---|
    # G   |->
    # H               |->
    # I                           |->
    # J                             <-|
    # K                 <-|
    # L     <-|                           VALID
    # M               <--->
    context "span_model.start_date && span_model.end_date.nil" do
      before(:each) do
        span_model = ScopedModel.create!(:start_date => Date.today - 2.days, :end_date => nil)
      end

      context "A) start_date < span_model.start_date && end_date < span_model.start_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today - 3.days)
          scoped_model.should be_valid
          scoped_model.overlap?(span_model).should be_false
        end
      end

      context "B) start_date < span_model.start_date && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "C) start_date < span_model.start_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "D) start_date IN span && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "E) start_date IN span && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 4.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "F) start_date > span_model.end_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "G) start_date < span_model.start_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "H) start_date IN span && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "I) start_date > span_model.end_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "J) start_date nil && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "K) start_date nil && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "L) start_date nil && end_date < span_model.start_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today - 3.days)
          scoped_model.should be_valid
          scoped_model.overlap?(span_model).should be_false
        end
      end

      context "M) start_date nil && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end
    end

    #    -4  -3  -2  -1  +1  +2  +3  +4
    #     <-------------------|           TEST SPAN
    # A   |---|
    # B   |---------------|
    # C   |---------------------------|
    # D               |---|
    # E               |---------------|
    # F                           |---|   VALID
    # G   |->
    # H               |->
    # I                           |->     VALID
    # J                             <-|
    # K                 <-|
    # L     <-|
    # M               <--->
    context "span_model.start_date.nil && span_model.end_date" do
      before(:each) do
        span_model = ScopedModel.create!(:start_date => nil, :end_date => Date.today + 2.day)
      end

      context "A) start_date < span_model.start_date && end_date < span_model.start_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today - 3.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "B) start_date < span_model.start_date && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "C) start_date < span_model.start_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "D) start_date IN span && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "E) start_date IN span && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 4.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "F) start_date > span_model.end_date && end_date > span_model.end_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => Date.today + 4.days)
          scoped_model.should be_valid
          scoped_model.overlap?(span_model).should be_false
        end
      end

      context "G) start_date < span_model.start_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "H) start_date IN span && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "I) start_date > span_model.end_date && end_date nil" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => nil)
          scoped_model.should be_valid
          scoped_model.overlap?(span_model).should be_false
        end
      end

      context "J) start_date nil && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "K) start_date nil && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "L) start_date nil && end_date < span_model.start_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today - 3.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "M) start_date nil && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end
    end

    #    -4  -3  -2  -1  +1  +2  +3  +4
    #     <--------------------------->   TEST SPAN
    # A   |---|
    # B   |---------------|
    # C   |---------------------------|
    # D               |---|
    # E               |---------------|
    # F                           |---|
    # G   |->
    # H               |->
    # I                           |->
    # J                             <-|
    # K                 <-|
    # L     <-|
    # M               <--->
    context "span_model.start_date.nil && span_model.end_date.nil" do
      before(:each) do
        span_model = ScopedModel.create!(:start_date => nil, :end_date => nil)
      end

      context "A) start_date < span_model.start_date && end_date < span_model.start_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today - 3.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "B) start_date < span_model.start_date && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "C) start_date < span_model.start_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "D) start_date IN span && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "E) start_date IN span && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 4.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "F) start_date > span_model.end_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "G) start_date < span_model.start_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "H) start_date IN span && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "I) start_date > span_model.end_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "J) start_date nil && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 4.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "K) start_date nil && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 1.day)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "L) start_date nil && end_date < span_model.start_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today - 3.days)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end

      context "M) start_date nil && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => nil)
          scoped_model.should_not be_valid
          scoped_model.overlap?(span_model).should be_true
        end
      end
    end
  end
end
