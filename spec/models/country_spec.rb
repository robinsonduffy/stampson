require 'spec_helper'

describe Country do
  before(:each) do
    @attr = { :name => "Test Country" }
  end
  
  it "should create a new user given valid attributes" do
    Country.create!(@attr)
  end
  
  describe "validations" do
    it "should require a name" do
      no_name_country = Country.new(@attr.merge(:name => ' '))
      no_name_country.should_not be_valid
    end
    
    it "should require a unique name" do
      Country.create!(@attr)
      same_name_country = Country.new(@attr)
      same_name_country.should_not be_valid  
    end
  end
  
end
