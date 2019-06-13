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
      raise "Failed to disable user #{@user.username}: #{e.message}"
    end
  end

  def object
    @user
  end

end
