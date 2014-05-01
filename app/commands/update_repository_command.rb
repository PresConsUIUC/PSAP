class UpdateRepositoryCommand < Command

  def initialize(repository, repository_params, user, remote_ip)
    @repository = repository
    @repository_params = repository_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    @repository.update!(@repository_params)
    Event.create(description: "Updated repository \"#{@repository.name}\" in "\
    "institution \"#{@repository.institution.name}\"",
                 user: @user, address: @remote_ip,
                 event_status: EventStatus::SUCCESS)
  end

  def object
    @repository
  end

end
