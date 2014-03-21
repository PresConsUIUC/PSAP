class SessionsController < ApplicationController

  def new

  end

  def create
    user = User.find_by(username: params[:session][:username].downcase,
                        enabled: true,
                        confirmed: true)
    if user && user.authenticate(params[:session][:password])
      sign_in user

      # Log the successful signin
      Event.create(description: "User #{user.username} signed in",
                   user: user)
      user.last_login = Time.now
      user.log_update?(false)
      user.save

      redirect_back_or dashboard_path
    else
      sleep 2 # slow down brute-force attacks
      flash.now[:error] = 'Invalid username/password combination.'
      render 'new'
    end
  end

  def destroy
    user = current_user

    sign_out

    # Log the signout
    Event.create(description: "User #{user.username} signed out",
                 user: user)

    redirect_to root_url
  end

end
