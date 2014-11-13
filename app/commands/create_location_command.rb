class CreateLocationCommand < Command

  def initialize(repository, location_params, doing_user, remote_ip)
    @doing_user = doing_user
    @remote_ip = remote_ip

    @location = repository.locations.build(
        location_params.except(:assessment_question_responses))

    # the AQR params from the form are not in a rails-compatible format
    if location_params[:assessment_question_responses]
      location_params[:assessment_question_responses].each_value do |option_id|
        option = AssessmentQuestionOption.find(option_id)
        if option.is_a?(AssessmentQuestionOption) and
            option.assessment_question.is_a?(AssessmentQuestion)
          @location.assessment_question_responses << AssessmentQuestionResponse.new(
              assessment_question_option: option,
              assessment_question: option.assessment_question)
        end
      end
    end
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
      @location.events << Event.create(
          description: "Attempted to create location, but failed: "\
          "#{@location.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to create location: #{@location.errors.full_messages[0]}"
    rescue => e
      @location.events << Event.create(
          description: "Attempted to create location, but failed: "\
          "#{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to create location: #{e.message}"
    else
      @location.events << Event.create(
          description: "Created location \"#{@location.name}\" in "\
          "repository \"#{@repository.name}\"",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @location
  end

end
