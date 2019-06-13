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
      # Fail if a non-admin user is trying to create the repository in a
      # different institution
      if @doing_user && (!@doing_user.is_admin? && @doing_user.institution != @institution)
        raise 'Insufficient privileges'
      end

      @repository.save!
    rescue ActiveRecord::RecordInvalid
      raise ValidationError, "Failed to create repository: "\
      "#{@repository.errors.full_messages[0]}"
    rescue => e
      raise "Failed to create repository: #{e.message}"
    end
  end

  def object
    @repository
  end

end
