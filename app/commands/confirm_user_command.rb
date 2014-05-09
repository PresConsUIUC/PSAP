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
      @user.enabled = true
      @user.save!
      Event.create(description: "Confirmed user #{@user.username}",
                   user: @user, address: @remote_ip)
    elsif @confirmation_code != @user.confirmation_code
      Event.create(description: "Invalid confirmation code supplied for user "\
      "#{@user.username}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
    else
      Event.create(description: "User #{@user.username} attempted to "\
      "confirm account, but was already confirmed.",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::NOTICE)
    end
  end

  def object
    @user
  end

end
