class PasswordController < ApplicationController

  invisible_captcha only: :send_email

  ##
  # Responds to GET /forgot-password, displaying a form that will POST to
  # /forgot_password.
  #
  def forgot_password
    # noop
  end

  ##
  # Responds to POST /forgot-password, sending an email containing a password
  # reset link and redirecting to the root URL.
  #
  def send_email
    if params[:email]
      @user = User.find_by_email params[:email]
      if @user
        @user.reset_password_reset_key
        @user.save!
        UserMailer.password_reset_email(@user).deliver_now unless
            Rails.env.test?
        flash[:notice] = 'An email has been sent containing a link to reset '\
                          'your password.'
        redirect_to root_url
      else
        flash['error'] = 'No user found with the given email address.'
        redirect_to forgot_password_url
      end
      return
    end
    redirect_to root_url
  end

  ##
  # Responds to GET /new-password, which handles incoming links from password
  # reset emails, and contains a form with new-password fields that will POST
  # to /new-password.
  #
  def new_password
    @user = User.find_by_username params[:username]
    if !@user or !@user.password_reset_key or
        params[:key] != @user.password_reset_key
      redirect_to root_url
    end
  end

  ##
  # Responds to POST /new-password. Resets the password.
  #
  def reset_password
    if params[:user].kind_of?(Hash)
      @user = User.find_by_username params[:user][:username]
      if @user and
          params[:user][:password_reset_key] == @user.password_reset_key
        @user.password_reset_key = nil
        @user.update_attributes(user_change_password_params)
        flash['success'] = 'Password reset successfully.'
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
