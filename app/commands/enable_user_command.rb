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

      ActiveRecord::Base.transaction do
        @user.enabled = true
        @user.save!
        UserMailer.welcome_email(@user).deliver_now unless @user.last_signin
      end
    rescue => e
      raise "Failed to enable user #{@user.username}: #{e.message}"
    end
  end

  def object
    @user
  end

end
