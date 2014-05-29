class UpdateResourceCommand < Command

  def initialize(resource, resource_params, doing_user, remote_ip)
    @resource = resource
    @resource_params = resource_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @resource.update!(@resource_params)
    rescue ActiveRecord::RecordInvalid
      Event.create(description: "Attempted to update resource "\
      "\"#{@resource.name},\" but failed: #{@resource.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to update resource \"#{@resource.name}\": "\
            "#{@resource.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Failed to update resource "\
      "\"#{@resource.name},\" but failed:: #{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to update resource \"#{@resource.name}\": #{e.message}"
    else
      Event.create(description: "Updated resource \"#{@resource.name}\" in "\
      "location \"#{@resource.location.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @resource
  end

end
