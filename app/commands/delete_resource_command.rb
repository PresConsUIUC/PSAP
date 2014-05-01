class DeleteResourceCommand < Command

  def initialize(resource, user, remote_ip)
    @resource = resource
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    @resource.destroy!
    Event.create(description: "Deleted resource \"#{@resource.name}\" from "\
    "location \"#{@resource.location.name}\"",
                 user: @user, address: @remote_ip,
                 event_status: EventStatus::SUCCESS)
  end

  def object
    @resource
  end

end
