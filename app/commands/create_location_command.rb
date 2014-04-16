class CreateLocationCommand < Command

  def initialize(repository, location_params, user, remote_ip)
    @repository = repository
    @location_params = location_params
    @user = user
    @location = @repository.locations.build(@location_params)
    @remote_ip = remote_ip
  end

  def execute
    @location.save!
    Event.create(description: "Created location \"#{@location.name}\" in "\
    "repository \"#{@repository.name}\"",
                 user: @user, address: @remote_ip)
  end

  def object
    @location
  end

end
