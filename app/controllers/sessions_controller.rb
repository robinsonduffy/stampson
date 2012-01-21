class SessionsController < ApplicationController
  def new
    if !current_user
      @title = "Sign In"
    else
      redirect_to root_path
    end
  end
  
  def create
    user = login(params[:email].downcase, params[:password],params[:remember_me])
    if user
      flash[:success] = "Welcome, #{user.email}!"
      redirect_back_or_to root_path
    else
      flash.now[:error] = "The credentials you entered were invalid"
      render :new
    end
  end
  
  def destroy
    logout
    flash[:success] = "You have been logged out"
    redirect_to root_path
  end

end
