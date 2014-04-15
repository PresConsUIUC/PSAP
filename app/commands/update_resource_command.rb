class UpdateResourceCommand < Command

  def initialize(resource, resource_params, user)
    @resource = resource
    @resource_params = resource_params
    @user = user
  end

  def execute
    # TODO: update @resource.percent_complete
    raise CommandError, 'Failed to update resource' unless
        @resource.update_attributes(@resource_params)

    Event.create(description: "Updated resource \"#{@resource.name}\" in "\
    "location \"#{@resource.location.name}\"",
                 user: @user)
  end

  def object
    @resource
  end

end
