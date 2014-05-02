class UpdateResourceCommand < Command

  def initialize(resource, resource_params, user, remote_ip)
    @resource = resource
    @resource_params = resource_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @resource.update!(@resource_params)
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to update resource "\
      "\"#{@resource.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    rescue => e
      Event.create(description: "Failed to update resource "\
      "\"#{@resource.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Updated resource \"#{@resource.name}\" in "\
      "location \"#{@resource.location.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @resource
  end

end
