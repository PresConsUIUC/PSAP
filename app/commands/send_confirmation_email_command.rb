class SendConfirmationEmailCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise 'Insufficient privileges' if !@doing_user.is_admin?

      UserMailer.confirm_account_email(@user).deliver_now
    rescue => e
      @user.events << Event.create(
          description: "Attempted to send a confirmation email to user "\
          "#{@user.username}, but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to send confirmation email to user #{@user.username}: #{e.message}"
    else
      @user.events << Event.create(
          description: "Sent confirmation email to user #{@user.username}",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @user
  end

end
