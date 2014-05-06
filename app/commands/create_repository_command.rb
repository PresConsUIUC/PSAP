class CreateRepositoryCommand < Command

  def initialize(institution, repository_params, user, remote_ip)
    @institution = institution
    @repository_params = repository_params
    @user = user
    @repository = @institution.repositories.build(@repository_params)
    @remote_ip = remote_ip
  end

  def execute
    begin
      @repository.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Failed to create repository: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to create repository: #{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: "Created repository \"#{@repository.name} "\
      "in institution \"#{@repository.institution.name}\"",
                   user: @user, address: @remote_ip)
    end
  end

  def object
    @repository
  end

end
