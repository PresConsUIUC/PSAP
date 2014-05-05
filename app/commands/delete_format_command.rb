class DeleteFormatCommand < Command

  def initialize(format, user, remote_ip)
    @format = format
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @format.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      Event.create(description: "Failed to delete format: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to delete format: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::WARNING,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Deleted format \"#{@format.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @format
  end

end
