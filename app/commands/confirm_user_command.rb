class ConfirmUserCommand < Command

  def initialize(user, confirmation_code, remote_ip)
    @user = user
    @confirmation_code = confirmation_code
    @remote_ip = remote_ip
  end

  def execute
    if !@user.confirmed && @confirmation_code == @user.confirmation_code
      @user.confirmed = true
      @user.confirmation_code = nil
      @user.enabled = false # admin needs to approve
      @user.save!
      AdminMailer.account_approval_request_email(@user).deliver_now
    elsif @confirmation_code != @user.confirmation_code
      raise 'Invalid confirmation code.'
    else
      raise 'Your account is already confirmed.'
    end
  end

  def object
    @user
  end

end
