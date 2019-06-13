class SignOutCommand < Command

  def initialize(user, remote_ip)
    @user = user
    @remote_ip = remote_ip
  end

  def execute
  end

  def object
    @user
  end

end
