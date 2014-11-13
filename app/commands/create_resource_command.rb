class CreateResourceCommand < Command

  def initialize(location, resource_params, doing_user, remote_ip)
    @doing_user = doing_user
    @remote_ip = remote_ip

    @resource = location.resources.build(
        resource_params.except(:assessment_question_responses))
    @resource.user ||= doing_user

    # the AQR params from the form are not in a rails-compatible format
    if resource_params[:assessment_question_responses]
      resource_params[:assessment_question_responses].each_value do |option_id|
        option = AssessmentQuestionOption.find(option_id)
        if option.is_a?(AssessmentQuestionOption) and
            option.assessment_question.is_a?(AssessmentQuestion)
          @resource.assessment_question_responses << AssessmentQuestionResponse.new(
              assessment_question_option: option,
              assessment_question: option.assessment_question)
        end
      end
    end
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
      @resource.events << Event.create(
          description: "Attempted to create resource, but failed: "\
          "#{@resource.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to create resource: #{@resource.errors.full_messages[0]}"
    rescue => e
      @resource.events << Event.create(
          description: "Attempted to create resource, but failed: "\
          "#{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to create resource: #{e.message}"
    else
      @resource.events << Event.create(
          description: "Created resource \"#{@resource.name}\" in "\
          "location \"#{@resource.location.name}\"",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @resource
  end

end
