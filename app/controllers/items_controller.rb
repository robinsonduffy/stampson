class ItemsController < ApplicationController
  before_filter :require_login, :only => [:new, :create, :edit, :update]
  before_filter :require_admin, :only => [:new, :create, :edit, :update]
  
  def new
    @title = "Create New Item"
    @item = Item.new
  end

  def create
    @item = Item.new(params[:item])
    country = Country.find_by_name(params[:country]) || Country.new({:name => params[:country]})
    if country.save
      #good country
      country.reload
      @item.country_id = country.id
      if @item.save
        #set up any prices
        i = 0
        valid_prices = true
        if(params[:prices] && params[:conditions])
          params[:prices].each do |price|
            if(valid_prices && (!price.empty? || !params[:conditions][i].empty?))
              test_price = @item.prices.build({:price => price, :condition => params[:conditions][i]})
              valid_prices = test_price.valid?
            end
            i += 1
          end
          if valid_prices
            @item.save
          else
            @title = "Create New Item"
            @item.destroy
            flash.now[:error] = "The prices/conditions you entered were not valid"
            render :new and return
          end
        end
        flash[:success] = "Item Successfully Created"
        redirect_to new_item_path
      else
        #bad item
        @title = "Create New Item"
        render :new and return
      end
    else
      @title = "Create New Item"
      flash.now[:error] = "The country you entered isn't valid"
      render :new and return
      #bad country
    end
  end
  
  def edit
    @item = Item.find_by_id(params[:id])
    @title = "Edit Item"
  end
  
  def update
    @item = Item.find_by_id(params[:id])
    #check if we need to update the country
    if @item.country.name != params[:country]
      country = Country.find_by_name(params[:country]) || Country.new({:name => params[:country]})
      if country.save
        #good country
        country.reload
        @item.country_id = country.id
      else
        #bad country
        @title = "Edit Item"
        flash.now[:error] = "The country you entered isn't valid"
        render :edit and return
      end
    end
    #build any new prices...update any existing prices
    conditions_to_keep = []
    i = 0
    params[:conditions].each do |condition|
      conditions_to_keep.push(condition) if (!condition.empty? && !condition.include?(condition))
      if @item.prices.find_by_condition(condition).nil?
        #new price
        @item.prices.build({:price => params[:prices][i], :condition => condition})
      else
        #existing price
        #unmark it for destruction
        @item.prices.find_by_condition(condition).reload
        #change the parameters
        @item.prices.find_by_condition(condition).price = params[:prices][i]
      end
    end
    #mark all the not needed prices for deletion
    for price in @item.prices do 
      if !conditions_to_keep.include?(price.condition)
        price.mark_for_destruction 
      end
    end
    #update the basic item attributes
    if(@item.update_attributes(params[:item]))
      #everything checked out
      flash[:success] = 'Item Changed'
      redirect_to(root_path) #for now
    else
      #we had a problem
      @title = "Edit Item"
      render :edit and return
    end
  end

end
