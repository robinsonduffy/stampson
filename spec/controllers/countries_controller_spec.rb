require 'spec_helper'

describe CountriesController do
  render_views
  describe "GET 'show'" do
    before(:each) do
      @country = Factory(:country)
      (1..10).each do |number|
        Factory(:item, :scott_number => number.to_s, :country => @country)
      end
    end
    
    it "should be successful" do
      get :show, :id => @country
    end
    
    it "should have the right title" do
      get :show, :id => @country
      response.should have_selector("title", :content => @country.name)
    end
    
    it "should list all of the stamps" do
      get :show, :id => @country
      @country.items.sell.each do |item|
        response.should have_selector(".scott_number", :content => item.scott_number)
      end
    end
    
    describe "for non-admins" do
      it "should not have links to edit the items" do
        get :show, :id => @country
        @country.items.sell.each do |item|
          response.should_not have_selector("a", :href => edit_item_path(item.id))
        end
      end
    end
    
    describe "for admin users" do
      before(:each) do
        login_user(Factory(:user, :admin => true))
      end
      
      it "should have links to edit the items" do
        get :show, :id => @country
        @country.items.sell.each do |item|
          response.should have_selector("a", :href => edit_item_path(item.id))
        end
      end
      
    end
    
  end

end
