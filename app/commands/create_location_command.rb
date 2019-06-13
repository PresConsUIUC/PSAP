class CreateLocationCommand < Command

  def initialize(repository, location_params, doing_user, remote_ip)
    @doing_user = doing_user
    @remote_ip = remote_ip
    @repository = repository
    @location = repository.locations.build(
        location_params.except(:assessment_question_responses))
  end

  def execute
    begin
      # Fail if a non-admin user is trying to create the location in a
      # different institution
      if @doing_user && !@doing_user.is_admin? &&
          @doing_user.institution != @repository.institution
        raise 'Insufficient privileges'
      end

      @location.save!
    rescue ActiveRecord::RecordInvalid
      raise ValidationError,
            "Failed to create location: #{@location.errors.full_messages[0]}"
    rescue => e
      raise "Failed to create location: #{e.message}"
    end
  end

  def object
    @location
  end

end
