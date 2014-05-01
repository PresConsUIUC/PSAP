class EnableUserCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @user.enabled = true
      @user.save!
    rescue => e
      Event.create(description: "Failed to enable user #{@user.username}: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Enabled user #{@user.username}",
                   user: @doing_user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @user
  end

end
