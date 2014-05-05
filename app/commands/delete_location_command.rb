class DeleteLocationCommand < Command

  def initialize(location, user, remote_ip)
    @location = location
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @location.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      Event.create(description: "Failed to delete location: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to delete location: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Deleted location \"#{@location.name}\" from "\
      "repository \"#{@location.repository.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @location
  end

end
