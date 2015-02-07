class CloneResourceCommand < Command

  def initialize(resource, doing_user, remote_ip)
    @resource = resource
    @doing_user = doing_user
    @remote_ip = remote_ip
    @cloned_resource = @resource.dup
    @cloned_resource.name = ('Clone of ' +
        @cloned_resource.name)[0..@cloned_resource.class.max_length(:name) - 1]
  end

  def execute
    begin
      @cloned_resource.save!
    rescue => e
      @resource.events << Event.create(
          description: "Attempted to clone resource #{@resource.name}, "\
          "but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to clone resource #{@resource.name}: #{e.message}"
    else
      @resource.events << Event.create(
          description: "Cloned resource #{@resource.name}",
          user: @doing_user, address: @remote_ip)
      @cloned_resource.events << Event.create(
          description: "Cloned resource #{@resource.name}",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @cloned_resource
  end

end
