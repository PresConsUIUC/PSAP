class DisableUserCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise "#{@doing_user.username} has insufficient privileges to "\
      "disable users." unless @doing_user.is_admin?

      @user.enabled = false
      @user.save!
    rescue => e
      @user.events << Event.create(
          description: "Attempted to disable user #{@user.username}, "\
          "but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ALERT)
      raise "Failed to disable user #{@user.username}: #{e.message}"
    else
      @user.events << Event.create(
          description: "Disabled user #{@user.username}",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @user
  end

end
