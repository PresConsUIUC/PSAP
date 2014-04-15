class CreateLocationCommand < Command

  def initialize(repository, location_params, user)
    @repository = repository
    @location_params = location_params
    @user = user
  end

  def execute
    @location = @repository.locations.build(@location_params)
    raise CommandError, 'Failed to save location' unless @location.save

    Event.create(description: "Created location \"#{@location.name}\" in "\
    "repository \"#{@repository.name}\"",
                 user: @user)
  end

  def object
    @location
  end

end
