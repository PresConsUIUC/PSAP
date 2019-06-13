class SendConfirmationEmailCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise 'Insufficient privileges' unless @doing_user.is_admin?

      UserMailer.confirm_account_email(@user).deliver_now
    rescue => e
      raise "Failed to send confirmation email to user #{@user.username}: #{e.message}"
    end
  end

  def object
    @user
  end

end
