class SignOutCommand < Command

  def initialize(user, remote_ip)
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    Event.create(description: "User #{@user.username} signed out",
                 user: @user, address: @remote_ip) if @user
  end

  def object
    @user
  end

end
