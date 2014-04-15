class CreateLocationCommand < Command

  def initialize(repository, location_params, user)
    @repository = repository
    @location_params = location_params
    @user = user
    @location = @repository.locations.build(@location_params)
  end

  def execute
    raise CommandError, 'Failed to save location' unless @location.save

    Event.create(description: "Created location \"#{@location.name}\" in "\
    "repository \"#{@repository.name}\"",
                 user: @user)
  end

  def object
    @location
  end

end
