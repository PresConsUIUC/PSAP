class DeleteLocationCommand < Command

  def initialize(location, user, remote_ip)
    @location = location
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    @location.destroy!
    Event.create(description: "Deleted location \"#{@location.name}\" from "\
    "repository \"#{@location.repository.name}\"",
                 user: @user, address: @remote_ip)
  end

  def object
    @location
  end

end
