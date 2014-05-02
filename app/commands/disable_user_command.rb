class DisableUserCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @user.enabled = false
      @user.save!
    rescue => e
      Event.create(description: "Failed to disable user #{@user.username}: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE,
                   event_level: EventLevel::ALERT)
      raise e
    else
      Event.create(description: "Disabled user #{@user.username}",
                   user: @doing_user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @user
  end

end
