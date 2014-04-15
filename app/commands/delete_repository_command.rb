class DeleteRepositoryCommand < Command

  def initialize(repository, user)
    @repository = repository
    @user = user
  end

  def execute
    @repository.destroy!
    Event.create(description: "Deleted repository \"#{@repository.name}\" from "\
    "institution \"#{@repository.institution.name}\"",
                 user: @user)
  end

  def object
    @repository
  end

end
