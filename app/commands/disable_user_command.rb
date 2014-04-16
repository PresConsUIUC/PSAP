class DisableUserCommand < Command

  def initialize(user, doing_user, remote_ip)
    @user = user
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    @user.enabled = false
    @user.save!

    Event.create(description: "Disabled user #{@user.username}",
                 user: @doing_user, address: @remote_ip)
  end

  def object
    @user
  end

end
