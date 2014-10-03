class EnableUserCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise "#{@doing_user.username} has insufficient privileges to "\
        "enable users." unless @doing_user.is_admin?

      UserMailer.welcome_email(@user).deliver unless @user.last_signin

      @user.enabled = true
      @user.save!
    rescue => e
      @user.events << Event.create(
          description: "Attempted to enable user #{@user.username}, "\
          "but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to enable user #{@user.username}: #{e.message}"
    else
      @user.events << Event.create(
          description: "Enabled user #{@user.username}",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @user
  end

end
