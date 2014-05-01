class DeleteRepositoryCommand < Command

  def initialize(repository, user, remote_ip)
    @repository = repository
    @user = user
    @address = remote_ip
  end

  def execute
    begin
      @repository.destroy!
    rescue => e
      Event.create(description: "Failed to delete repository: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Deleted repository \"#{@repository.name}\" "\
      "from institution \"#{@repository.institution.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @repository
  end

end
