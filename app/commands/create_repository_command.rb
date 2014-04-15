class CreateRepositoryCommand < Command

  def initialize(institution, repository_params, user)
    @institution = institution
    @repository_params = repository_params
    @user = user
  end

  def execute
    @repository = @institution.repositories.build(@repository_params)
    raise CommandError, 'Failed to save repository' unless @repository.save

    Event.create(description: "Created repository \"#{@repository.name}\" in "\
    "institution \"#{@repository.institution.name}\"",
                 user: @user)
  end

  def object
    @repository
  end

end
