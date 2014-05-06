class CreateLocationCommand < Command

  def initialize(repository, location_params, user, remote_ip)
    @repository = repository
    @location_params = location_params
    @user = user
    @location = @repository.locations.build(@location_params)
    @remote_ip = remote_ip
  end

  def execute
    begin
      @location.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to create location: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to create location: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Created location \"#{@location.name}\" in "\
      "repository \"#{@repository.name}\"",
                   user: @user, address: @remote_ip)
    end
  end

  def object
    @location
  end

end
