class CreateInstitutionCommand < Command

  def initialize(institution_params, doing_user, remote_ip)
    @doing_user = doing_user
    @remote_ip = remote_ip

    @institution = Institution.new(
        institution_params.except(:assessment_question_responses))

    # the AQR params from the form are not in a rails-compatible format
    if institution_params[:assessment_question_responses]
      institution_params[:assessment_question_responses].each_value do |option_id|
        option = AssessmentQuestionOption.find(option_id)
        if option.is_a?(AssessmentQuestionOption) and
            option.assessment_question.is_a?(AssessmentQuestion)
          @institution.assessment_question_responses << AssessmentQuestionResponse.new(
              assessment_question_option: option,
              assessment_question: option.assessment_question)
        end
      end
    end
  end

  def execute
    begin
      @institution.users << @doing_user if @doing_user
      @institution.save!
    rescue ActiveRecord::RecordInvalid
      @institution.events << Event.create(
          description: "Attempted to create institution, but failed: "\
          "#{@institution.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise ValidationError, "Failed to create institution: "\
      "#{@institution.errors.full_messages[0]}"
    rescue => e
      @institution.events << Event.create(
          description: "Attempted to create institution, but failed: "\
          "#{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to create institution: #{e.message}"
    else
      @institution.events << Event.create(
          description: "Created institution \"#{@institution.name}\"",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @institution
  end

end
