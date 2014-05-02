class UpdateLocationCommand < Command

  def initialize(location, location_params, user, remote_ip)
    @location = location
    @location_params = location_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @location.update!(@location_params)
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to update location "\
      "\"#{@location.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    rescue => e
      Event.create(description: "Failed to update location "\
      "\"#{@location.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Updated location \"#{@location.name}\" in "\
      "repository \"#{@location.repository.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @location
  end

end
