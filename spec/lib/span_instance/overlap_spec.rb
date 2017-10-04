require 'spec_helper'

RSpec.describe "a basic model using acts_as_span" do
  before do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table :multiple_scoped_models, force: true do |t|
        t.integer :parent_1_id
        t.integer :parent_2_id
        t.date :start_date
        t.date :end_date
      end

      create_table :single_scoped_models, force: true do |t|
        t.integer :parent_1_id
        t.date :start_date
        t.date :end_date
      end

      create_table :scoped_models, force: true do |t|
        t.date :start_date
        t.date :end_date
      end

      create_table :span_models, force: true do |t|
        t.date :start_date
        t.date :end_date
      end
    end

    class MultipleScopedModel < ActiveRecord::Base
      acts_as_span :span_overlap_count => 1, :span_overlap_scope => [:parent_1_id, :parent_2_id]
    end

    class SingleScopedModel < ActiveRecord::Base
      acts_as_span :span_overlap_scope => :parent_1_id
    end

    class ScopedModel < ActiveRecord::Base
      acts_as_span :span_overlap_count => 0
    end

    class SpanModel < ActiveRecord::Base
      acts_as_span :span_overlap_count => nil
    end

    ScopedModel.all.each(&:destroy)
  end


  #context "span_overlap_count == nil" do
  #  before(:each) do
  #    @span_model = SpanModel.create!(:start_date => Date.today - 2.days, :end_date => Date.today + 2.day)
  #  end
  #
  #  it "should be valid if overlap?" do
  #    non_scoped_model = SpanModel.new(:start_date => Date.today, :end_date => Date.today)
  #    non_scoped_model.should be_valid
  #    non_scoped_model.overlap?(@span_model).should be_true
  #  end
  #end
  #
  #context "span_overlap_count == 1, span_overlap_scope == Array" do
  #  before(:each) do
  #    @span_model = MultipleScopedModel.create!(:start_date => Date.today - 2.days, :end_date => Date.today + 2.day, :parent_1_id => 1, :parent_2_id => 2)
  #    @span_model_2 = MultipleScopedModel.create!(:start_date => Date.today - 2.days, :end_date => Date.today + 2.day, :parent_1_id => 1, :parent_2_id => 2)
  #  end
  #
  #  it "should NOT be valid if in scope && overlap?" do
  #    scoped_model = MultipleScopedModel.new(:start_date => Date.today, :end_date => Date.today, :parent_1_id => 1, :parent_2_id => 2)
  #    scoped_model.should_not be_valid
  #    scoped_model.overlap?(@span_model).should be_true
  #  end
  #
  #  it "should be valid if NOT in scope && overlap?" do
  #    scoped_model = MultipleScopedModel.new(:start_date => Date.today, :end_date => Date.today, :parent_1_id => 1, :parent_2_id => 0)
  #    scoped_model.should be_valid
  #    scoped_model.overlap?(@span_model).should be_true
  #  end
  #end
  #
  #context "span_overlap_count == nil, span_overlap_scope == symbol" do
  #  before(:each) do
  #    @span_model = SingleScopedModel.create!(:start_date => Date.today - 2.days, :end_date => Date.today + 2.day, :parent_1_id => 1)
  #  end
  #
  #  it "should NOT be valid if in scope && overlap?" do
  #    scoped_model = SingleScopedModel.new(:start_date => Date.today, :end_date => Date.today, :parent_1_id => 1)
  #    scoped_model.should_not be_valid
  #    scoped_model.overlap?(@span_model).should be_true
  #  end
  #
  #  it "should be valid if NOT in scope && overlap?" do
  #    scoped_model = SingleScopedModel.new(:start_date => Date.today, :end_date => Date.today, :parent_1_id => 0)
  #    scoped_model.should be_valid
  #    scoped_model.overlap?(@span_model).should be_true
  #  end
  #
  #  it "should ignore itself" do
  #    @span_model.should be_valid
  #  end
  #end

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
      before(:each) do
        @span_model = ScopedModel.create!(:start_date => Date.today - 2.days, :end_date => Date.today + 2.day)
      end

      context "A) start_date < span_model.start_date && end_date < span_model.start_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today - 3.days)
          expect(scoped_model).to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_falsey
        end
      end

      context "B) start_date < span_model.start_date && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "C) start_date < span_model.start_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "D) start_date IN span && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "E) start_date IN span && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 4.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "F) start_date > span_model.end_date && end_date > span_model.end_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => Date.today + 4.days)
          expect(scoped_model).to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_falsey
        end
      end

      context "G) start_date < span_model.start_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "H) start_date IN span && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "I) start_date > span_model.end_date && end_date nil" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => nil)
          expect(scoped_model).to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_falsey
        end
      end

      context "J) start_date nil && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "K) start_date nil && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "L) start_date nil && end_date < span_model.start_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today - 3.days)
          expect(scoped_model).to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_falsey
        end
      end

      context "M) start_date nil && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
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
        @span_model = ScopedModel.create!(:start_date => Date.today - 2.days, :end_date => nil)
      end

      context "A) start_date < span_model.start_date && end_date < span_model.start_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today - 3.days)
          expect(scoped_model).to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_falsey
        end
      end

      context "B) start_date < span_model.start_date && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "C) start_date < span_model.start_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "D) start_date IN span && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "E) start_date IN span && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 4.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "F) start_date > span_model.end_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "G) start_date < span_model.start_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "H) start_date IN span && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "I) start_date > span_model.end_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "J) start_date nil && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "K) start_date nil && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "L) start_date nil && end_date < span_model.start_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today - 3.days)
          expect(scoped_model).to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_falsey
        end
      end

      context "M) start_date nil && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
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
        @span_model = ScopedModel.create!(:start_date => nil, :end_date => Date.today + 2.day)
      end

      context "A) start_date < span_model.start_date && end_date < span_model.start_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today - 3.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "B) start_date < span_model.start_date && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "C) start_date < span_model.start_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "D) start_date IN span && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "E) start_date IN span && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 4.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "F) start_date > span_model.end_date && end_date > span_model.end_date" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => Date.today + 4.days)
          expect(scoped_model).to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_falsey
        end
      end

      context "G) start_date < span_model.start_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "H) start_date IN span && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "I) start_date > span_model.end_date && end_date nil" do
        it "should be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => nil)
          expect(scoped_model).to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_falsey
        end
      end

      context "J) start_date nil && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "K) start_date nil && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "L) start_date nil && end_date < span_model.start_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today - 3.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "M) start_date nil && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
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
        @span_model = ScopedModel.create!(:start_date => nil, :end_date => nil)
      end

      context "A) start_date < span_model.start_date && end_date < span_model.start_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today - 3.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "B) start_date < span_model.start_date && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "C) start_date < span_model.start_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "D) start_date IN span && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "E) start_date IN span && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => Date.today + 4.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "F) start_date > span_model.end_date && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "G) start_date < span_model.start_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 4.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "H) start_date IN span && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today - 1.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "I) start_date > span_model.end_date && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => Date.today + 3.days, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "J) start_date nil && end_date > span_model.end_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 4.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "K) start_date nil && end_date IN span" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today + 1.day)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "L) start_date nil && end_date < span_model.start_date" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => Date.today - 3.days)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end

      context "M) start_date nil && end_date nil" do
        it "should NOT be valid" do
          scoped_model = ScopedModel.new(:start_date => nil, :end_date => nil)
          expect(scoped_model).not_to be_valid
          expect(scoped_model.overlap?(@span_model)).to be_truthy
        end
      end
    end
  end
end
