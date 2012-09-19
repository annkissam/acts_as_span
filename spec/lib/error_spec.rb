require 'spec_helper' 

describe "class initialization errors" do
  it "should raise ArguementError if column does not exists" do
    lambda {
      build_model :error_model1 do
        string   :description
        
        acts_as_span
      end
    }.should raise_error(ArgumentError)
  end
  
  it "should raise ArguementError if column does not exists" do
    lambda {
      build_model :error_model2 do
        string   :description
        date     :start_date
        date     :end_date
        
        acts_as_span :started_date, :ended_date
      end
    }.should raise_error(ArgumentError)
  end
  
  it "should raise ArguementError if more than two parameters are used" do
    lambda {
      build_model :error_model3 do
        string   :description
        date     :start_date
        date     :end_date
      
        acts_as_span :start_date, :end_date, :something_else
      end
    }.should raise_error(ArgumentError)
  end
  
  it "should raise ArguementError if one parameter is used" do
    lambda {
      build_model :error_model4 do
        string   :description
        date     :start_date
        date     :end_date
      
        acts_as_span :start_date
      end
    }.should raise_error(ArgumentError)
  end
end