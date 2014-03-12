class SessionsController < ApplicationController

  def new

  end

  def create
    user = User.find_by(username: params[:session][:username].downcase)
    if user && user.confirmed && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user
    else
      sleep 2 # slow down brute-force attacks
      flash.now[:error] = 'Invalid username/password combination.'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end
