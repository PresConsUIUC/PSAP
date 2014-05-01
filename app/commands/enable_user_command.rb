class EnableUserCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    @user.enabled = true
    @user.save!

    Event.create(description: "Enabled user #{@user.username}",
                 user: @doing_user, address: @remote_ip,
                 event_status: EventStatus::SUCCESS)
  end

  def object
    @user
  end

end
