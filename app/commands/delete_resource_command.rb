class DeleteResourceCommand < Command

  def initialize(resource, user)
    @resource = resource
    @user = user
  end

  def execute
    @resource.destroy!
    Event.create(description: "Deleted resource \"#{@resource.name}\" from "\
    "location \"#{@resource.location.name}\"",
                 user: @user)
  end

  def object
    @resource
  end

end
