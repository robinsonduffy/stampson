require 'spec_helper'

describe Price do
  before(:each) do
    @country = Factory(:country)
    @item = Factory(:item, :country => @country)
    @attr = {:condition => "MNH", :price => 1.99, :item_id => @item.id }
  end
  
  it "should create a new price given valid attributes" do
    Price.create!(@attr)
  end
  
  describe "validations" do
    it "should require a condition" do
      bad_price = Price.new(@attr.merge(:condition => '  '))
      bad_price.should_not be_valid
    end
    
    it "should require a price" do
      bad_price = Price.new(@attr.merge(:price => '  '))
      bad_price.should_not be_valid
    end
    
    it "should require a numeric price" do
      bad_price = Price.new(@attr.merge(:price => 'A'))
      bad_price.should_not be_valid
    end
    
    it "should require a valid item_id" do
      bad_price = Price.new(@attr.merge(:item_id => @item.id + 1))
      bad_price.should_not be_valid
    end
    
    it "should require a unique item_id/condition" do
      Price.create!(@attr)
      bad_price = Price.new(@attr.merge(:price => 2.99))
      bad_price.should_not be_valid
    end
    
    it "should allow idnetical conditions for different items" do
      Price.create!(@attr)
      item2 = Factory(:item, :country => @country, :scott_number => '99-100')
      good_price = Price.new(@attr.merge(:item_id => item2.id))
      good_price.should be_valid
    end
    
  end
end
