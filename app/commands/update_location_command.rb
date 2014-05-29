class UpdateLocationCommand < Command

  def initialize(location, location_params, doing_user, remote_ip)
    @location = location
    @location_params = location_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @location.update!(@location_params)
    rescue ActiveRecord::RecordInvalid
      Event.create(description: "Attempted to update location "\
      "\"#{@location.name},\" but failed: #{@location.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to update location \"#{@location.name}\": "\
            "#{@location.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to update location "\
      "\"#{@location.name},\" but failed: #{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to update location \"#{@location.name}\": #{e.message}"
    else
      Event.create(description: "Updated location \"#{@location.name}\" in "\
      "repository \"#{@location.repository.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @location
  end

end
