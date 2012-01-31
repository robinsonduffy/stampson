class PagesController < ApplicationController
  before_filter :require_login, :only => [:admin]
  before_filter :require_admin, :only => [:admin]
  
  def home
  end
  
  def admin
    @title = 'Site Administration'
  end
  
  def shipping
    @title = 'Postage & Handling'
  end

end
