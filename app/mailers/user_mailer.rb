class UserMailer < ActionMailer::Base

  ##
  # Sent to the user's previous email address when their email has changed.
  #
  def change_email(user, old_email, new_email)
    @user = user
    @new_email = new_email
    @psap_url = root_url
    mail(to: old_email, subject: 'Your PSAP email has changed')
  end

  ##
  # Sent to the user when their feed key has changed.
  #
  def changed_feed_key_email(user)
    @user = user
    @psap_url = root_url
    mail(to: @user.email, subject: 'Your PSAP feed key has been changed')
  end

  ##
  # Sent to the user after s/he has initially signed up. Contains a
  # confirmation URL that must be followed.
  #
  def confirm_account_email(user)
    @user = user
    @confirm_url = confirm_user_url(@user, code: @user.confirmation_code)
    mail(to: @user.email, subject: 'Welcome to PSAP!')
  end

  def institution_change_approved_email(user)
    @user = user
    @psap_url = root_url
    mail(to: @user.email, subject: 'Your new PSAP institution has been approved')
  end

  def institution_change_refused_email(user)
    @user = user
    @psap_url = root_url
    mail(to: @user.email,
         subject: 'Your request to change your PSAP institution has been denied')
  end

  ##
  # Sent to the user after when password has been reset.
  #
  def password_reset_email(user)
    @user = user
    @password_reset_url = url_for(controller: 'password',
                                  action: 'new_password',
                                  only_path: false,
                                  username: @user.username,
                                  key: @user.password_reset_key)
    mail(to: @user.email, subject: 'Your request to reset your PSAP password')
  end

  ##
  # Sent to the user after they have been approved by an admin and are clear
  # to sign in and get started.
  #
  def welcome_email(user)
    @user = user
    @sign_in_url = signin_url
    mail(to: @user.email, subject: 'Your PSAP account has been approved!')
  end

end
