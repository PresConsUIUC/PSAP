class UpdateRepositoryCommand < Command

  def initialize(repository, repository_params, doing_user, remote_ip)
    @repository = repository
    @repository_params = repository_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @repository.update!(@repository_params)
    rescue ActiveRecord::RecordInvalid
      raise ValidationError,
            "Failed to update repository \"#{@repository.name}\": "\
            "#{@repository.errors.full_messages[0]}"
    rescue => e
      raise "Failed to update repository \"#{@repository.name}\": #{e.message}"
    end
  end

  def object
    @repository
  end

end
