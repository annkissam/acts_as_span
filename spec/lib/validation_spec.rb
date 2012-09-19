require 'spec_helper'

#The typical errors_on helper is not available, so we use a less DRY technique...

describe "a basic model using acts_as_span" do
  before(:all) do 
    build_model :validating_model do
      string   :description
      date     :start_date
      date     :end_date
      
      acts_as_span :start_date_field_required => true, :end_date_field_required => true
    end
    
    build_model :non_validating_model do
      string   :description
      date     :start_date
      date     :end_date
      
      acts_as_span
    end
  end
  
  context "validating_model" do
    it "should require a start_date" do
      validation_model = ValidatingModel.new(:start_date => nil, :end_date => Date.today)
      validation_model.should_not be_valid
      validation_model.errors[:start_date].should_not be_nil
    end
    
    it "should require an end_date" do
      validation_model = ValidatingModel.new(:start_date => Date.today, :end_date => nil)
      validation_model.should_not be_valid
      validation_model.errors[:end_date].should_not be_nil
    end
    
    context "end_date == start_date" do
      it "should be valid" do
        validation_model = ValidatingModel.new(:start_date => Date.today, :end_date => Date.today)
        validation_model.should be_valid
      end
    end
    
    context "end_date < start_date" do
      it "should NOT be valid" do
        validation_model = ValidatingModel.new(:start_date => Date.today, :end_date => Date.today - 1.day)
        validation_model.should_not be_valid
        validation_model.errors[:end_date].should_not be_nil
      end
    end
    
    context "end_date > start_date" do
      it "should be valid" do
        validation_model = ValidatingModel.new(:start_date => Date.today, :end_date => Date.today + 1.day)
        validation_model.should be_valid
      end
    end
    
    it "should be valid" do
      validation_model = ValidatingModel.new(:start_date => Date.today, :end_date => Date.today + 1.day)
      validation_model.should be_valid
    end
  end
  
  context "non_validating_model" do
    it "should NOT require a start_date" do
      validation_model = NonValidatingModel.new(:start_date => nil, :end_date => Date.today)
      validation_model.should be_valid
    end
    
    it "should NOT require an end_date" do
      validation_model = NonValidatingModel.new(:start_date => Date.today, :end_date => nil)
      validation_model.should be_valid
    end
    
    #this is condensed - it's really the same tests as above, we're just making sure nothing changes...
    it "should require an end_date >= start_date" do
      validation_model = NonValidatingModel.new(:start_date => Date.today, :end_date => Date.today)
      validation_model.should be_valid
      
      validation_model = NonValidatingModel.new(:start_date => Date.today, :end_date => Date.today - 1.day)
      validation_model.should_not be_valid
      validation_model.errors[:end_date].should_not be_nil
      
      validation_model = NonValidatingModel.new(:start_date => Date.today, :end_date => Date.today + 1.day)
      validation_model.should be_valid
    end
    
    it "should be valid" do
      validation_model = NonValidatingModel.new(:start_date => Date.today, :end_date => Date.today + 1.day)
      validation_model.should be_valid
    end
  end

end