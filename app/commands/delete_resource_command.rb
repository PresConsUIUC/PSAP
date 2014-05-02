class DeleteResourceCommand < Command

  def initialize(resource, user, remote_ip)
    @resource = resource
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @resource.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      Event.create(description: "Failed to delete resource: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    rescue => e
      Event.create(description: "Failed to delete resource: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Deleted resource \"#{@resource.name}\" from "\
      "location \"#{@resource.location.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @resource
  end

end
