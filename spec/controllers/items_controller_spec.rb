require 'spec_helper'

describe ItemsController do
  render_views
  describe "GET 'new'" do
    describe "for non users" do
      it "should deny access" do
        get :new
        response.should_not be_success
      end
    end
    
    describe "for non-admin users" do
      before(:each) do
        login_user(Factory(:user))
      end
      
      it "should deny access" do
        get :new
        response.should_not be_success
      end
    end
    
    describe "for admins" do
      before(:each) do
        login_user(Factory(:user, :admin => true))
      end
      
      it "should be success" do
        get :new
        response.should be_success
      end
      
      it "should have the right title" do
        get :new
        response.should have_selector("title", :content => "Create New Item")
      end
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @attr = {:scott_number => "99", :description => "A Test Item"}
    end
    
    describe "for non users" do
      it "should deny access" do
        post :create, :item => @attr, :country => "America"
        response.should redirect_to(login_path)
      end
    end
    
    describe "for non-admin users" do
      before(:each) do
        login_user(Factory(:user))
      end
      
      it "should deny access" do
        post :create, :item => @attr, :country => "America"
        response.should redirect_to(login_path)
      end
    end
    
    describe "for admin users" do
      before(:each) do
        login_user(Factory(:user, :admin => true))
      end
      
      describe "failure" do
        before(:each) do
          @bad_attr = {:scott_number => "", :description => ""}
        end
        
        it "should render the form again" do
          post :create, :item => @bad_attr, :country => "America"
          response.should render_template(:new)
        end
        
        it "should not create a new item" do
          lambda do
            post :create, :item => @bad_attr, :country => "America"
          end.should_not change(Item, :count)
        end
      end
      
      describe "success" do
        it "should create a new item" do
          lambda do
            post :create, :item => @attr, :country => "America"
          end.should change(Item, :count).by(1)
        end
        
        it "should redirect you back to the new item form" do
          post :create, :item => @attr, :country => "America"
          response.should redirect_to(new_item_path)
        end
        
        it "should display a success message" do
          post :create, :item => @attr, :country => "America"
          flash[:success].should =~ /created/i
        end
        
        describe "country handling" do
          it "should create a new country if needed" do
            lambda do
              post :create, :item => @attr, :country => "America"
            end.should change(Country, :count).by(1)
          end
          
          it "should re-use an existing country" do
            country = Factory(:country)
            lambda do
              post :create, :item => @attr, :country => country.name
            end.should_not change(Country, :count)
          end
        end
        
        describe "price handling" do
          describe "success" do
            it "should create new prices given correct attributes" do
              lambda do
                post :create, :item => @attr, :country => "America", :prices => ['1.99','2.10'], :conditions => ['MNH','TEST']
              end.should change(Price, :count).by(2)
            end
            
            it "should ignore blank price/conditions (as long as both are blank)" do
              lambda do
                post :create, :item => @attr, :country => "America", :prices => ['1.99',''], :conditions => ['MNH','']
              end.should change(Price, :count).by(1)
            end
          end
          
          describe "failure" do
            it "should error out" do
              lambda do
                post :create, :item => @attr, :country => "America", :prices => ['','2.10'], :conditions => ['MNH','TEST']
                response.should render_template(:new)
              end.should_not change(Price, :count)
            end
            
            it "should not create a new item either" do
              lambda do
                post :create, :item => @attr, :country => "America", :prices => ['','2.10'], :conditions => ['MNH','TEST']
              end.should_not change(Item, :count)
            end
          end
        end
      end
    end
  end
  
  describe "GET 'edit'" do
    before(:each) do
      @country = Factory(:country)
      @item = Factory(:item, :country => @country)
    end
    
    describe "for non users" do
      it "should deny access" do
        get :edit, :id => @item
        response.should redirect_to(login_path)
      end
    end
    
    describe "for non-admin users" do
      before(:each) do
        login_user(Factory(:user))
      end
      
      it "should deny access" do
        get :edit, :id => @item
        response.should redirect_to(login_path)
      end
    end
    
    describe "for admin users" do
      before(:each) do
        login_user(Factory(:user, :admin => true))
      end
      
      it "should be success" do
        get :edit, :id => @item
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @item
        response.should have_selector("title", :content => "Edit Item")
      end
      
      it "should have a delete link" do
        get :edit, :id => @item
        response.should have_selector("a", :content => "Delete Item")
      end
    end
  end
  
  describe "PUT 'update'" do
    before(:each) do
      @country = Factory(:country)
      @item = Factory(:item, :country => @country)
      @price1 = Factory(:price, :item => @item)
    end
    
    describe "for non users" do
      it "should deny access" do
        put :update, :id => @item
        response.should redirect_to(login_path)
      end
    end
    
    describe "for non-admin users" do
      before(:each) do
        login_user(Factory(:user))
      end
      
      it "should deny access" do
        put :update, :id => @item
        response.should redirect_to(login_path)
      end
    end
    
    describe "for admin users" do
      before(:each) do
        login_user(Factory(:user, :admin => true))
      end
      
      describe "failure" do
        before(:each) do
          @attr = {:scott_number => '', :description => ''}
        end
        
        describe "basic item failure" do
          it "should show the edit form again" do
            put :update, :id => @item, :item => @attr, :country => @item.country.name, :prices => [@item.prices.first.price], :conditions => [@item.prices.first.condition]
            response.should render_template(:edit)
          end
        
          it "should have the right title" do
            put :update, :id => @item, :item => @attr, :country => @item.country.name, :prices => [@item.prices.first.price], :conditions => [@item.prices.first.condition]
            response.should have_selector("title", :content => "Edit Item")
          end
        end
        
        describe "country failure" do
          it "should show the edit form again" do
            put :update, :id => @item, :item => {:scott_number => @item.scott_number, :description => @item.description}, :country => '', :prices => [@item.prices.first.price], :conditions => [@item.prices.first.condition]
            response.should render_template(:edit)
          end
        
          it "should have the right title" do
            put :update, :id => @item, :item => {:scott_number => @item.scott_number, :description => @item.description}, :country => '', :prices => [@item.prices.first.price], :conditions => [@item.prices.first.condition]
            response.should have_selector("title", :content => "Edit Item")
          end
        end
        
        describe "price failure" do
          it "should show the edit form again" do
            put :update, :id => @item, :item => {:scott_number => @item.scott_number, :description => @item.description}, :country => @item.country.name, :prices => [@item.prices.first.price], :conditions => ['']
            response.should render_template(:edit)
          end
        
          it "should have the right title" do
            put :update, :id => @item, :item => {:scott_number => @item.scott_number, :description => @item.description}, :country => @item.country.name, :prices => [@item.prices.first.price], :conditions => ['']
            response.should have_selector("title", :content => "Edit Item")
          end
        end
        
      end
      
      describe "success" do
        before(:each) do
          @attr = {:scott_number => '300-301', :description => 'Changed'}
        end
        
        it "should change the item's basic attributes" do
          put :update, :id => @item, :item => @attr, :country => @item.country.name, :prices => [@item.prices.first.price], :conditions => [@item.prices.first.condition]
          @item.reload
          @item.scott_number.should == @attr[:scott_number]
          @item.description.should == @attr[:description]
        end
        
        it "should redirect to the root path(for now)" do
          put :update, :id => @item, :item => @attr, :country => @item.country.name, :prices => [@item.prices.first.price], :conditions => [@item.prices.first.condition]
          response.should redirect_to(@country)
        end
        
        it "should flash a success message" do
          put :update, :id => @item, :item => @attr, :country => @item.country.name, :prices => [@item.prices.first.price], :conditions => [@item.prices.first.condition]
          flash[:success].should =~ /changed/i
        end
        
        describe "successful country changes" do
          it "should change the country (adding a new one if necessary)" do
            lambda do
              put :update, :id => @item, :item => @attr, :country => 'A New Country', :prices => [@item.prices.first.price], :conditions => [@item.prices.first.condition]
              @item.reload
              @item.country.name.should == "A New Country"
            end.should change(Country, :count).by(1)
          end
        end
        
        describe "successful price change" do
          it "should change an existing condition/price" do
            put :update, :id => @item, :item => @attr, :country => @item.country.name, :prices => ['0.15'], :conditions => [@item.prices.first.condition]
            @item.reload
            @item.prices.first.price.should == 0.15
          end
          
          it "should add a new item, leaving existing ones" do
            put :update, :id => @item, :item => @attr, :country => @item.country.name, :prices => [@item.prices.first.price, '0.15'], :conditions => [@item.prices.first.condition, 'TEST']
            @item.reload
            @item.prices.first.price.should == 1.99
            @item.prices.first.condition.should == 'MNH'
            @item.prices.last.price.should == 0.15
            @item.prices.last.condition.should == 'TEST'
            @item.prices.count.should == 2
          end
          
          it "should get rid of any conditions/prices that were removed by user" do
            @price2 = Factory(:price, :item => @item, :condition => 'TEST', :price => '0.15')
            put :update, :id => @item, :item => @attr, :country => @item.country.name, :prices => ['','0.15'], :conditions => ['','TEST']
            @item.reload
            @item.prices.first.condition.should == 'TEST'
            @item.prices.first.price.should == 0.15
            @item.prices.count.should == 1
          end
        end
      end
    end
    
  end
  
  describe "DELETE 'destroy'" do
    before(:each) do
      @country = Factory(:country)
      @item = Factory(:item, :country => @country)
      @price1 = Factory(:price, :item => @item)
    end
    
    describe "for non users" do
      it "should deny access" do
        delete :destroy, :id => @item
        response.should redirect_to(login_path)
      end
    end
    
    describe "for non-admin users" do
      before(:each) do
        login_user(Factory(:user))
      end
      
      it "should deny access" do
        delete :destroy, :id => @item
        response.should redirect_to(login_path)
      end
    end
    
    describe "for admin users" do
      before(:each) do
        login_user(Factory(:user, :admin => true))
      end
      
      it "should delete the item" do
        lambda do
          delete :destroy, :id => @item
        end.should change(Item, :count).by(-1)
      end
      
      it "should delete the item's prices" do
        lambda do
          delete :destroy, :id => @item
        end.should change(Price, :count).by(-1)
      end
    
      it "should redirect to the user index page" do
        delete :destroy, :id => @item
        response.should redirect_to(country_path(@item.country))
      end
    
      it "should display a confirmation message" do
        delete :destroy, :id => @item
        flash[:success] =~ /deleted/i
      end
    end
  end

end
