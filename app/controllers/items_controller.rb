class ItemsController < ApplicationController
  before_filter :require_login, :only => [:new, :create]
  before_filter :require_admin, :only => [:new, :create]
  
  def new
    @title = "Create New Item"
    @item = Item.new
    @country = Country.new
  end

  def create
    @item = Item.new(params[:item])
    @country = Country.find_by_name(params[:country]) || Country.new({:name => params[:country]})
    if @country.save
      #good country
      @country.reload
      @item.country_id = @country.id
      if @item.save
        flash[:success] = "Item Successfully Created"
        redirect_to new_item_path
      else
        #bad item
        @title = "Create New Item"
        render :new
      end
    else
      @title = "Create New Item"
      flash.now[:error] = "The country you entered isn't valid"
      render :new
      #bad country
    end
  end

end
