class UserMailer < ActionMailer::Base

  def change_email(user, old_email, new_email)
    @user = user
    @new_email = new_email
    @psap_url = root_url
    mail(to: old_email, subject: 'Your PSAP email has changed')
  end

  def changed_feed_key_email(user)
    @user = user
    @psap_url = root_url
    mail(to: @user.email, subject: 'Your PSAP feed key has been changed')
  end

  def password_reset_email(user)
    @user = user
    @password_reset_url = url_for(controller: 'password',
                                  action: 'new_password',
                                  only_path: false,
                                  username: @user.username,
                                  key: @user.password_reset_key)
    mail(to: @user.email, subject: 'Your request to reset your PSAP password')
  end

  def welcome_email(user)
    @user = user
    @confirmation_url = url_for(controller: 'users',
                                action: 'confirm',
                                only_path: false,
                                username: @user.username,
                                code: @user.confirmation_code)
    mail(to: @user.email, subject: 'Welcome to PSAP!')
  end
end
