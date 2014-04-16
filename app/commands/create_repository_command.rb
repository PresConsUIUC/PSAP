class CreateRepositoryCommand < Command

  def initialize(institution, repository_params, user, remote_ip)
    @institution = institution
    @repository_params = repository_params
    @user = user
    @repository = @institution.repositories.build(@repository_params)
    @remote_ip = remote_ip
  end

  def execute
    @repository.save!
    Event.create(description: "Created repository \"#{@repository.name}\" in "\
    "institution \"#{@repository.institution.name}\"",
                 user: @user, address: @remote_ip)
  end

  def object
    @repository
  end

end
