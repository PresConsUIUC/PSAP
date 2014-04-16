class UpdateResourceCommand < Command

  def initialize(resource, resource_params, user, remote_ip)
    @resource = resource
    @resource_params = resource_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    # TODO: update @resource.percent_complete
    @resource.update!(@resource_params)
    Event.create(description: "Updated resource \"#{@resource.name}\" in "\
    "location \"#{@resource.location.name}\"",
                 user: @user, address: @remote_ip)
  end

  def object
    @resource
  end

end
