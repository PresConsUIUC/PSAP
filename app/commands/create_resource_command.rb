class CreateResourceCommand < Command

  def initialize(location, resource_params, user, remote_ip)
    @user = user
    @resource = location.resources.build(resource_params)
    @remote_ip = remote_ip
  end

  def execute
    begin
      @resource.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to create resource: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    rescue => e
      Event.create(description: "Failed to create resource: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Created resource \"#{@resource.name}\" in "\
      "location \"#{@resource.location.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @resource
  end

end
