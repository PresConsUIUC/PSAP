class AdminMailer < ActionMailer::Base

  ##
  # Sent to the PSAP email address after a user has initially signed up.
  # Contains a confirmation URL that must be followed.
  #
  def account_approval_request_email(user)
    @user = user
    @user_url = url_for(user)
    mail(to: Psap::Application.config.psap_email_address,
         subject: 'New PSAP user requests account approval')
  end

  ##
  # Sent to the PSAP email address after a user requests to move to a different
  # (or initial) institution.
  #
  def institution_change_review_request_email(user)
    @user = user
    @user_url = url_for(user)
    mail(to: Psap::Application.config.psap_email_address,
         subject: 'PSAP user requests to change institutions')
  end

end
