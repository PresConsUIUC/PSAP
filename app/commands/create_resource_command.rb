class CreateResourceCommand < Command

  def initialize(location, resource_params, doing_user, remote_ip)
    @doing_user = doing_user
    @remote_ip = remote_ip
    @resource = location.resources.build(
        resource_params.except(:assessment_question_responses))
    @resource.user ||= doing_user
  end

  def execute
    begin
      # Fail if a non-admin user is trying to create the resource in a
      # different institution
      if @doing_user && !@doing_user.is_admin? &&
          @doing_user.institution != @resource.location.repository.institution
        raise 'Insufficient privileges'
      end
      @resource.save!
    rescue ActiveRecord::RecordInvalid
      raise ValidationError,
            "Failed to create resource: #{@resource.errors.full_messages[0]}"
    rescue => e
      raise "Failed to create resource: #{e.message}"
    end
  end

  def object
    @resource
  end

end
