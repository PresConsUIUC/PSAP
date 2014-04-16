class CreateResourceCommand < Command

  def initialize(location, resource_params, user, remote_ip)
    @user = user
    @resource = location.resources.build(resource_params)
    @remote_ip = remote_ip
  end

  def execute
    @resource.save!
    Event.create(description: "Created resource \"#{@resource.name}\" in "\
    "location \"#{@resource.location.name}\"",
                 user: @user, address: @remote_ip)
  end

  def object
    @resource
  end

end
