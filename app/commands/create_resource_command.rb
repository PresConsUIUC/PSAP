class CreateResourceCommand < Command

  def initialize(location, resource_params, user)
    @location = location
    @resource_params = resource_params
    @user = user
  end

  def execute
    @resource = @location.resources.build(@resource_params)
    raise CommandError, 'Failed to save resource' unless @resource.save

    Event.create(description: "Created resource #{@resource.name} in "\
    "location #{@resource.location.name}",
                 user: @user)
  end

  def object
    @resource
  end

end
