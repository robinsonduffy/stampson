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
        response.should_not be_success
      end
    end
    
    describe "for non-admin users" do
      before(:each) do
        login_user(Factory(:user))
      end
      
      it "should deny access" do
        post :create, :item => @attr, :country => "America"
        response.should_not be_success
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

end
