class ResetUserFeedKeyCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @user.reset_feed_key
      @user.save!

      # TODO: send an email notifying the user that their feed key has changed
    rescue => e
      Event.create(description: "Failed to reset feed key for user "\
      "#{@user.username}: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Reset feed key for user #{@user.username}",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @user
  end

end
