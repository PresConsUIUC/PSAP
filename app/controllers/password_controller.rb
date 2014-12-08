class PasswordController < ApplicationController

  ##
  # Responds to GET /forgot_password, displaying a form that will POST to
  # /forgot_password.
  #
  def forgot_password
    # noop
  end

  ##
  # Responds to POST /forgot_password, sending an email containing a password
  # reset link and redirecting to the root URL.
  #
  def send_email
    if params[:user].kind_of?(Hash)
      @user = User.find_by_email params[:user][:email]
      if @user
        @user.password_reset_key = SecureRandom.urlsafe_base64(nil, false) # TODO: put this in User.reset_reset_password_key
        @user.save!
        UserMailer.password_reset_email(@user).deliver unless Rails.env.test?
        flash[:notice] = 'An email has been sent containing a link to reset '\
                          'your password.'
      end
    end
    redirect_to root_url
  end

  ##
  # Responds to GET /new_password, which handles incoming links from password
  # reset emails, and contains a form with new-password fields that will POST
  # to /new_password.
  #
  def new_password
    @user = User.find_by_username params[:username]
    if !@user or !@user.password_reset_key or
        params[:key] != @user.password_reset_key
      redirect_to root_url
    end
  end

  ##
  # Responds to POST /new_password. Resets the password.
  #
  def reset_password
    if params[:user].kind_of?(Hash)
      @user = User.find_by_username params[:user][:username]
      if @user and
          params[:user][:password_reset_key] == @user.password_reset_key
        @user.password_reset_key = nil
        @user.update_attributes(user_change_password_params)
        flash[:success] = 'Password reset successfully.'
        return redirect_to signin_url
      end
    end
    redirect_to root_url
  end

  private

  def user_change_password_params
    params.require(:user).permit(:username, :password, :password_confirmation,
                                 :password_reset_key)
  end

end
