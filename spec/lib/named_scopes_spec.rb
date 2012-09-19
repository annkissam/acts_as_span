require 'spec_helper'

describe "a basic model using acts_as_span" do
  before(:all) do 
    build_model :span_model do
      string   :description
      date     :start_date
      date     :end_date
      
      acts_as_span
    end
  end
  
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
        SpanModel.current.should_not include(@span_model)
        @span_model.current?.should be_false
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should be included in #expired" do
        SpanModel.expired.should include(@span_model)
        @span_model.expired?.should be_true
      end
    end
    
    context "B) start_date < today & end_date == today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today - 2.day, :end_date => Date.today)
      end
      
      it "should be included in #current" do
        SpanModel.current.should include(@span_model)
        @span_model.current?.should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "C) start_date < today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today - 2.day, :end_date => Date.today + 2.day)
      end
      
      it "should be included in #current" do
        SpanModel.current.should include(@span_model)
        @span_model.current?.should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "D) start_date == today & end_date == today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today, :end_date => Date.today)
      end
      
      it "should be included in #current" do
        SpanModel.current.should include(@span_model)
        @span_model.current?.should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "E) start_date == today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today, :end_date => Date.today + 2.day)
      end
      
      it "should be included in #current" do
        SpanModel.current.should include(@span_model)
        @span_model.current?.should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "F) start_date > today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today + 1.day, :end_date => Date.today + 2.days)
      end
      
      it "should NOT be included in #current" do
        SpanModel.current.should_not include(@span_model)
        @span_model.current?.should be_false
      end
      
      it "should be included in #future" do
        SpanModel.future.should include(@span_model)
        @span_model.future?.should be_true
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "G) start_date < today & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today - 2.day, :end_date => nil)
      end
      
      it "should be included in #current" do
        SpanModel.current.should include(@span_model)
        @span_model.current?.should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "H) start_date == today & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today, :end_date => nil)   
      end
      
      it "should be included in #current" do
        SpanModel.current.should include(@span_model)
        @span_model.current?.should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "I) start_date > today & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => Date.today + 1.day, :end_date => nil)
      end
      
      it "should NOT be included in #current" do
        SpanModel.current.should_not include(@span_model)
        @span_model.current?.should be_false
      end
      
      it "should be included in #future" do
        SpanModel.future.should include(@span_model)
        @span_model.future?.should be_true
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "J) start_date == nil & end_date < today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => Date.today - 1.day)
      end
      
      it "should NOT be included in #current" do
        SpanModel.current.should_not include(@span_model)
        @span_model.current?.should be_false
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should be included in #expired" do
        SpanModel.expired.should include(@span_model)
        @span_model.expired?.should be_true
      end
    end
    
    context "K) start_date == nil & end_date == today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => Date.today)
      end
      
      it "should be included in #current" do
        SpanModel.current.should include(@span_model)
        @span_model.current?.should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "L) start_date == nil & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => Date.today + 2.day)
      end
      
      it "should be included in #current" do
        SpanModel.current.should include(@span_model)
        @span_model.current?.should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
    
    context "M) start_date == nil & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => nil)
      end
      
      it "should be included in #current" do
        SpanModel.current.should include(@span_model)
        @span_model.current?.should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future.should_not include(@span_model)
        @span_model.future?.should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired.should_not include(@span_model)
        @span_model.expired?.should be_false
      end
    end
  end
end