class ItemsController < ApplicationController
  before_filter :require_login, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :require_admin, :only => [:new, :create, :edit, :update, :destroy]
  
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
    #gather together our prices and do some simple validations
    entered_conditions = Hash.new
    i = 0
    params[:conditions].each do |condition|
      if entered_conditions[condition].nil? 
        entered_conditions[condition] = params[:prices][i]
      else
        @title = "Edit Item"
        flash.now[:error] = "The conditions/prices you entered weren't valid"
        render :edit and return
      end
      i += 1
    end
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
    #update any existing prices
    for price in @item.prices do
      if params[:conditions].include?(price.condition)
        price.price = entered_conditions[price.condition]
      else
        price.mark_for_destruction
      end
    end
    #build any new prices
    i = 0
    params[:conditions].each do |condition|
      if @item.prices.find_by_condition(condition).nil?
        @item.prices.build({:price => params[:prices][i], :condition => condition})
      end
      i += 1
    end
    #update the basic item attributes
    if(@item.update_attributes(params[:item]))
      #everything checked out
      flash[:success] = 'Item Changed'
      redirect_to(@item.country) #for now
    else
      #we had a problem
      @title = "Edit Item"
      render :edit and return
    end
  end
  
  def destroy
    item = Item.find(params[:id]).destroy
    flash[:success] = "Item deleted (#{item.country.name}: #{item.scott_number})"
    redirect_to country_path(item.country)
  end

end
