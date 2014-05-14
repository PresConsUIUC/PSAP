class CreateResourceCommand < Command

  def initialize(location, resource_params, doing_user, remote_ip)
    @doing_user = doing_user
    @resource = location.resources.build(resource_params)
    @remote_ip = remote_ip
  end

  def execute
    begin
      @resource.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Attempted to create resource, but failed: "\
      "#{@resource.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise "Failed to create resource: #{@resource.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to create resource, but failed: "\
      "#{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to create resource: #{e.message}"
    else
      Event.create(description: "Created resource \"#{@resource.name}\" in "\
      "location \"#{@resource.location.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @resource
  end

end
