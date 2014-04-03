class SessionsController < ApplicationController

  before_action :signed_out_user, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(username: params[:session][:username].downcase,
                        enabled: true,
                        confirmed: true)
    if user && user.authenticate(params[:session][:password])
      sign_in user

      # Log the successful signin
      Event.create(description: "User #{user.username} signed in from #{request.remote_ip}",
                   user: user)
      user.last_signin = Time.now
      user.log_update?(false)
      user.save

      cookies[:show_welcome_panel] = 1 if user.institution.nil?

      redirect_back_or dashboard_path
    else
      Event.create(description: "Sign-in failed: #{params[:session][:username].downcase} (#{request.remote_ip})")

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

  private

  def signed_out_user
    if signed_in?
      redirect_to root_url
    end
  end

end
