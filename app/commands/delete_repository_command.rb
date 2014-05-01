class DeleteRepositoryCommand < Command

  def initialize(repository, user, remote_ip)
    @repository = repository
    @user = user
    @address = remote_ip
  end

  def execute
    @repository.destroy!
    Event.create(description: "Deleted repository \"#{@repository.name}\" from "\
    "institution \"#{@repository.institution.name}\"",
                 user: @user, address: @remote_ip,
                 event_status: EventStatus::SUCCESS)
  end

  def object
    @repository
  end

end
