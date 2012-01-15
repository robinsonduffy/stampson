class ItemsController < ApplicationController
  before_filter :require_login, :only => [:new, :create]
  before_filter :require_admin, :only => [:new, :create]
  
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

end
