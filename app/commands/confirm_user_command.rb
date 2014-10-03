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

      UserMailer.account_approval_request_email(@user).deliver

      @user.save!
      @user.events << Event.create(
          description: "Confirmed user #{@user.username}",
          user: @user, address: @remote_ip)
    elsif @confirmation_code != @user.confirmation_code
      @user.events << Event.create(
          description: "Invalid confirmation code supplied for user "\
          "#{@user.username}",
          user: @user, address: @remote_ip, event_level: EventLevel::ERROR)
      raise 'Invalid confirmation code.'
    else
      @user.events << Event.create(
          description: "User #{@user.username} attempted to "\
          "confirm account, but was already confirmed.",
          user: @user, address: @remote_ip, event_level: EventLevel::NOTICE)
      raise 'Your account is already confirmed.'
    end
  end

  def object
    @user
  end

end
