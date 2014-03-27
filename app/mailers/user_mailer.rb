class UserMailer < ActionMailer::Base

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
