require 'spec_helper'

describe "a basic model using acts_as_span" do
  before(:all) do 
    build_model :span_model do
      string   :description
      date     :start_date
      date     :end_date
      
      acts_as_span
    end
    
    @query_date = Date.today + 1.month
  end
  
  context "named_scopes and current_on?, expired_on?, and future_on?" do
    context "start_date < today & end_date < today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date - 2.days, :end_date => @query_date - 1.day)
      end
      
      it "should NOT be included in #current" do
        SpanModel.current_on(@query_date).should_not include(@span_model)
        @span_model.current_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should be included in #expired" do
        SpanModel.expired_on(@query_date).should include(@span_model)
        @span_model.expired_on?(@query_date).should be_true
      end
    end
    
    context "start_date < today & end_date == today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date - 1.day, :end_date => @query_date)
      end
      
      it "should NOT be included in #current" do
        SpanModel.current_on(@query_date).should_not include(@span_model)
        @span_model.current_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should be included in #expired" do
        SpanModel.expired_on(@query_date).should include(@span_model)
        @span_model.expired_on?(@query_date).should be_true
      end
    end
    
    context "start_date < today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date - 1.day, :end_date => @query_date + 1.day)
      end
      
      it "should be included in #current" do
        SpanModel.current_on(@query_date).should include(@span_model)
        @span_model.current_on?(@query_date).should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired_on(@query_date).should_not include(@span_model)
        @span_model.expired_on?(@query_date).should be_false
      end
    end
    
    context "start_date == today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date, :end_date => @query_date + 1.day)
      end
      
      it "should be included in #current" do
        SpanModel.current_on(@query_date).should include(@span_model)
        @span_model.current_on?(@query_date).should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired_on(@query_date).should_not include(@span_model)
        @span_model.expired_on?(@query_date).should be_false
      end
    end
    
    context "start_date > today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date + 1.day, :end_date => @query_date + 2.days)
      end
      
      it "should NOT be included in #current" do
        SpanModel.current_on(@query_date).should_not include(@span_model)
        @span_model.current_on?(@query_date).should be_false
      end
      
      it "should be included in #future" do
        SpanModel.future_on(@query_date).should include(@span_model)
        @span_model.future_on?(@query_date).should be_true
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired_on(@query_date).should_not include(@span_model)
        @span_model.expired_on?(@query_date).should be_false
      end
    end
    
    context "start_date < today & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date - 1.day, :end_date => @query_date + 1.day)
      end
      
      it "should be included in #current" do
        SpanModel.current_on(@query_date).should include(@span_model)
        @span_model.current_on?(@query_date).should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired_on(@query_date).should_not include(@span_model)
        @span_model.expired_on?(@query_date).should be_false
      end
    end
    
    context "start_date < today & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date - 1.day, :end_date => nil)
      end
      
      it "should be included in #current" do
        SpanModel.current_on(@query_date).should include(@span_model)
        @span_model.current_on?(@query_date).should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired_on(@query_date).should_not include(@span_model)
        @span_model.expired_on?(@query_date).should be_false
      end
    end
    
    context "start_date == today & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date, :end_date => nil)   
      end
      
      it "should be included in #current" do
        SpanModel.current_on(@query_date).should include(@span_model)
        @span_model.current_on?(@query_date).should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired_on(@query_date).should_not include(@span_model)
        @span_model.expired_on?(@query_date).should be_false
      end
    end
    
    context "include start_date > today & end_date == nil" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => @query_date + 1.day, :end_date => nil)
      end
      
      it "should NOT be included in #current" do
        SpanModel.current_on(@query_date).should_not include(@span_model)
        @span_model.current_on?(@query_date).should be_false
      end
      
      it "should be included in #future" do
        SpanModel.future_on(@query_date).should include(@span_model)
        @span_model.future_on?(@query_date).should be_true
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired_on(@query_date).should_not include(@span_model)
        @span_model.expired_on?(@query_date).should be_false
      end
    end
    
    context "start_date == nil & end_date < today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => @query_date - 1.day)
      end
      
      it "should NOT be included in #current" do
        SpanModel.current_on(@query_date).should_not include(@span_model)
        @span_model.current_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should be included in #expired" do
        SpanModel.expired_on(@query_date).should include(@span_model)
        @span_model.expired_on?(@query_date).should be_true
      end
    end
    
    context "start_date == nil & end_date == today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => @query_date)
      end
      
      it "should NOT be included in #current" do
        SpanModel.current_on(@query_date).should_not include(@span_model)
        @span_model.current_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should be included in #expired" do
        SpanModel.expired_on(@query_date).should include(@span_model)
        @span_model.expired_on?(@query_date).should be_true
      end
    end
    
    context "start_date == nil & end_date > today" do
      before(:all) do
        @span_model = SpanModel.create!(:start_date => nil, :end_date => @query_date + 1.day)
      end
      
      it "should be included in #current" do
        SpanModel.current_on(@query_date).should include(@span_model)
        @span_model.current_on?(@query_date).should be_true
      end
      
      it "should NOT be included in #future" do
        SpanModel.future_on(@query_date).should_not include(@span_model)
        @span_model.future_on?(@query_date).should be_false
      end
      
      it "should NOT be included in #expired" do
        SpanModel.expired_on(@query_date).should_not include(@span_model)
        @span_model.expired_on?(@query_date).should be_false
      end
    end
  end
end