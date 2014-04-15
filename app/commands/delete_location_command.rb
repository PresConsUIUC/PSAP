class DeleteLocationCommand < Command

  def initialize(location, user)
    @location = location
    @user = user
  end

  def execute
    @location.destroy!
    Event.create(description: "Deleted location \"#{@location.name}\" from "\
    "repository \"#{@location.repository.name}\"",
                 user: @user)
  end

  def object
    @location
  end

end
