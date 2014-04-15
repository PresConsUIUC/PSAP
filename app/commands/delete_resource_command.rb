class DeleteResourceCommand < Command

  def initialize(resource, user)
    @resource = resource
    @user = user
  end

  def execute
    raise CommandError, 'Failed to delete resource' unless @resource.destroy

    Event.create(description: "Deleted resource \"#{@resource.name}\" from "\
    "location \"#{@resource.location.name}\"",
                 user: @user)
  end

  def object
    @resource
  end

end
