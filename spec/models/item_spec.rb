require 'spec_helper'

describe Item do
  before(:each) do
    @country = Factory(:country)
    @attr = {:scott_number => "100", :description => "A Test Item", :country_id => @country.id }
  end
  
  it "should create a new item given valid attributes" do
    Item.create!(@attr)
  end
  
  describe "validations" do
    it "should require a scott_number" do
      bad_item = Item.new(@attr.merge(:scott_number => '  '))
      bad_item.should_not be_valid
    end
    
    it "should require a country_id" do
      bad_item = Item.new(@attr.merge(:country_id => '  '))
      bad_item.should_not be_valid
    end
    
    it "should require a country_id for a valid country" do
      bad_item = Item.new(@attr.merge(:country_id => @country.id + 1))
      bad_item.should_not be_valid
    end
    
    it "should require unique scott_number/country_id combination" do
      Item.create!(@attr)
      bad_item = Item.new(@attr.merge(:description => "A different item"))
      bad_item.should_not be_valid
    end
    
    it "should allow identical scott_numbers for different countries" do
      Item.create!(@attr)
      country2 = Factory(:country, :name => "Country 2")
      good_item = Item.new(@attr.merge(:description => "A different item", :country_id => country2.id))
      good_item.should be_valid
    end
  end
  
  describe "country association" do
    before(:each) do
      @item = Factory(:item, :country => @country)
    end
    
    it "should have a 'country' attribute" do
      @item.should respond_to(:country)
    end
    
    it "should have the right country" do
      @item.country.should == @country
    end
  end
  
  describe "price association" do
    before(:each) do
      @item = Factory(:item, :country => @country)
      @price1 = Factory(:price, :price => 1.99, :condition => 'A', :item => @item)
      @price2 = Factory(:price, :price => 0.99, :condition => 'B', :item => @item)
      @price3 = Factory(:price, :price => 2.99, :condition => 'C', :item => @item)
      @price4 = Factory(:price, :price => 1.13, :condition => 'D', :item => @item)
      @price5 = Factory(:price, :price => 1.30, :condition => 'E', :item => @item)
    end
    
    it "should have a prices attribute" do
      @item.should respond_to(:prices)
    end
    
    it "should return the right prices in the right order" do
      @item.prices.should == [@price3, @price1, @price5, @price4, @price2]
    end
  end
  
end
