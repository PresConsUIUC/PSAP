class UserMailer < ActionMailer::Base

  default from: 'alexd@illinois.edu' # TODO: fix

  def welcome_email(user)
    @user = user
    @confirmation_url = url_for(controller: 'users',
                                action: 'confirm',
                                only_path: false,
                                username: @user.username,
                                confirmation_code: @user.confirmation_code)
    mail(to: @user.email, subject: 'Welcome to PSAP!')
  end
end
