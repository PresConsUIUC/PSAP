class PasswordController < ApplicationController

  # Responds to GET /forgot_password
  def forgot_password
    # Displays a form that will POST to /forgot_password.
  end

  # Responds to POST /forgot_password
  def send_email
    @user = User.find_by_username params[:username]
    if @user
      @user.reset_password_key = SecureRandom.urlsafe_base64(nil, false)
      @user.save!
      UserMailer.welcome_email(@user).deliver
      flash[:success] = 'An email has been sent containing a link to reset
                        your password.'
    end
    redirect_to root_url
  end

  # Responds to GET /new_password, which handles incoming links from password
  # reset emails.
  def new_password
    @user = User.find_by_username params[:username]
    if !@user || params[:key] != @user.reset_password_key
      redirect_to root_url
    end
  end

  # Responds to POST /new_password
  def reset_password
    @user = User.find_by_username params[:username]
    if @user
      @user.reset_password_key = nil;
      @user.update_attributes(user_change_password_params)
      flash[:success] = 'Password reset successfully.'
      redirect_to login_url
    end
    redirect_to root_url
  end

  private

  def user_change_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
