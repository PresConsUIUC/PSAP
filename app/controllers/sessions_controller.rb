class SessionsController < ApplicationController

  before_action :signed_out_user, only: [:new, :create]

  def new
  end

  def create
    if params[:session]
      user = User.find_by(username: params[:session][:username].downcase,
                          enabled: true,
                          confirmed: true)
      if user && user.authenticate(params[:session][:password])
        sign_in user

        # Log the successful signin
        Event.create(description: "User #{user.username} signed in",
                     user: user, address: request.remote_ip)
        user.last_signin = Time.now
        user.save

        cookies[:show_welcome_panel] = 1 if user.institution.nil?

        redirect_back_or dashboard_path
        return
      end
    end

    message = 'Sign-in failed (no username provided)'
    if params[:session]
      message = "Sign-in failed for #{params[:session][:username].downcase}"
    end
    Event.create(description: message, address: request.remote_ip,
                 event_level: EventLevel::NOTICE)

    flash[:error] = 'Invalid username/password combination.'
    redirect_to signin_url
  end

  def destroy
    user = current_user

    sign_out

    # Log the signout
    if user
      Event.create(description: "User #{user.username} signed out",
                   user: user, address: request.remote_ip)
    end

    redirect_to root_url
  end

  private

  def signed_out_user
    if signed_in?
      redirect_to root_url
    end
  end

end
