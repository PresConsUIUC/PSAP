class UpdateLocationCommand < Command

  def initialize(location, location_params, user)
    @location = location
    @location_params = location_params
    @user = user
  end

  def execute
    raise CommandError, 'Failed to update location' unless
        @location.update_attributes(@location_params)

    Event.create(description: "Updated location \"#{@location.name}\" in "\
    "repository \"#{@location.repository.name}\"",
                 user: @user)
  end

  def object
    @location
  end

end
