class UpdateRepositoryCommand < Command

  def initialize(repository, repository_params, user, remote_ip)
    @repository = repository
    @repository_params = repository_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @repository.update!(@repository_params)
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to update repository "\
      "\"#{@repository.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    rescue => e
      Event.create(description: "Failed to update repository "\
      "\"#{@repository.name}\": #{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: "Updated repository \"#{@repository.name}\" in "\
      "institution \"#{@repository.institution.name}\"",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @repository
  end

end
