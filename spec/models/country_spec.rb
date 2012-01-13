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
  
  describe "item association" do
    before(:each) do
      @country = Country.create(@attr)
      @item1 = Factory(:item, :scott_number => "100", :country => @country)
      @item8 = Factory(:item, :scott_number => "99B", :country => @country)
      @item6 = Factory(:item, :scott_number => "99A", :country => @country)
      @item2 = Factory(:item, :scott_number => "99", :country => @country)
      @item5 = Factory(:item, :scott_number => "99-104", :country => @country)
      @item4 = Factory(:item, :scott_number => "999", :country => @country)
      @item7 = Factory(:item, :scott_number => "B100", :country => @country)
      @item3 = Factory(:item, :scott_number => "A100", :country => @country)
    end
    
    it "should have an 'items' attribute" do
      @country.should respond_to(:items)
    end
    
    #it "should have the right items in the right order" do
      #@country.items.should == [@item2, @item6,@item8,@item5,@item1,@item4,@item3,@item7]
    #end
  end
end
