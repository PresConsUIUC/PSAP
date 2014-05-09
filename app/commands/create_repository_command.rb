class CreateRepositoryCommand < Command

  def initialize(institution, repository_params, doing_user, remote_ip)
    @institution = institution
    @repository_params = repository_params
    @doing_user = doing_user
    @repository = @institution.repositories.build(@repository_params)
    @remote_ip = remote_ip
  end

  def execute
    begin
      @repository.save!
    rescue ActiveRecord::RecordInvalid => e
      Event.create(description: "Attempted to create repository, but failed: "\
      "#{@repository.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise "Failed to create repository: "\
      "#{@repository.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to create repository, but failed: "\
      "#{@repository.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to create repository: "\
      "#{@repository.errors.full_messages[0]}"
    else
      Event.create(description: "Created repository \"#{@repository.name} "\
      "in institution \"#{@repository.institution.name}\"",
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @repository
  end

end
