class UpdateRepositoryCommand < Command

  def initialize(repository, repository_params, user)
    @repository = repository
    @repository_params = repository_params
    @user = user
  end

  def execute
    raise CommandError, 'Failed to update repository' unless
        @repository.update_attributes(@repository_params)

    Event.create(description: "Updated repository #{@repository.name} in "\
    "institution #{@repository.institution.name}",
                 user: @user)
  end

  def object
    @repository
  end

end
