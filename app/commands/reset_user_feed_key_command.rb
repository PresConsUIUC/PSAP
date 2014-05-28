class ResetUserFeedKeyCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      # Fail if a non-admin user is trying to reset someone else's feed key
      if !@doing_user.is_admin? && @user != @doing_user
        raise 'Insufficient privileges'
      end

      @user.reset_feed_key
      @user.save!
      UserMailer.changed_feed_key_email(@user).deliver if @user != @doing_user
    rescue => e
      Event.create(description: "Attempted to reset feed key for user "\
      "#{@user.username}, but failed: #{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to reset feed key for user #{@user.username}: #{e.message}"
    else
      Event.create(description: "Reset feed key for user #{@user.username}",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @user
  end

end
