class DeleteLocationCommand < Command

  def initialize(location, doing_user, remote_ip)
    @location = location
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @location.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      raise e # this should never happen
    rescue => e
      Event.create(description: "Attempted to delete location "\
      "\"#{@location.name},\" but failed: #{@location.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to delete location: #{@location.errors.full_messages[0]}"
    else
      Event.create(description: "Deleted location \"#{@location.name}\" from "\
      "repository \"#{@location.repository.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @location
  end

end
