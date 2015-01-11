class DeleteResourceCommand < Command

  def initialize(resource, doing_user, remote_ip)
    @resource = resource
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @resource.destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      raise e # this should never happen
    rescue => e
      @resource.events << Event.create(
          description: "Attempted to delete resource \"#{@resource.name}\", "\
          "but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to delete resource \"#{@resource.name}\": "\
      "#{e.message}"
    else
      @resource.location.events << Event.create(
          description: "Deleted resource \"#{@resource.name}\" from "\
          "location \"#{@resource.location.name}\"",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @resource
  end

end
