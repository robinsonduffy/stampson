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
    
  end
  
  describe "active countries list" do
    it "should have an 'active' attribute" do
      Country.should respond_to(:active)
    end
  end
  
  describe "sell method" do
    before(:each) do
      @country1 = Factory(:country, :name => "Country A")
      @country2 = Factory(:country, :name => "Country B")
      @country3 = Factory(:country, :name => "Country C")
      @country4 = Factory(:country, :name => "Country D")
      item1 = Factory(:item, :country => @country1)
      item2 = Factory(:item, :country => @country2)
      item4 = Factory(:item, :country => @country4)
      Factory(:price, :item => item1, :condition => "MNH")
      Factory(:price, :item => item2, :condition => "MNH")
      Factory(:price, :item => item4, :condition => "BUY")
    end
    it "should have a sell method" do
      Country.should respond_to(:sell)
    end
    
    it "should return only the countries with items to sell" do
      sell_list = Country.active.sell
      sell_list.should include(@country1)
      sell_list.should include(@country2)
      sell_list.should_not include(@country3)
      sell_list.should_not include(@country4)
    end
  end
  
  describe "buy method" do
    before(:each) do
      @country1 = Factory(:country, :name => "Country A")
      @country2 = Factory(:country, :name => "Country B")
      @country3 = Factory(:country, :name => "Country C")
      @country4 = Factory(:country, :name => "Country D")
      item1 = Factory(:item, :country => @country1)
      item2 = Factory(:item, :country => @country2)
      item4 = Factory(:item, :country => @country4)
      Factory(:price, :item => item1, :condition => "MNH")
      Factory(:price, :item => item2, :condition => "BUY")
      Factory(:price, :item => item4, :condition => "BUY")
    end
    it "should have a buy method" do
      Country.should respond_to(:buy)
    end
    
    it "should return only the countries with items to buy" do
      buy_list = Country.active.buy
      buy_list.should include(@country2)
      buy_list.should include(@country4)
      buy_list.should_not include(@country1)
      buy_list.should_not include(@country3)
    end
  end
end
