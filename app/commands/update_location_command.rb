class UpdateLocationCommand < Command

  def initialize(location, location_params, user, remote_ip)
    @location = location
    @location_params = location_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    @location.update!(@location_params)
    Event.create(description: "Updated location \"#{@location.name}\" in "\
    "repository \"#{@location.repository.name}\"",
                 user: @user, address: @remote_ip,
                 event_status: EventStatus::SUCCESS)
  end

  def object
    @location
  end

end
