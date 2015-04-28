class UpdateInstitutionCommand < Command

  def initialize(institution, institution_params, doing_user, remote_ip)
    @institution = institution
    @institution_params = institution_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      # Fail if a non-admin user is trying to update an institution to which
      # s/he does not belong
      if @doing_user and !@doing_user.is_admin? and
          @doing_user.institution != @institution
        raise 'Insufficient privileges'
      end

      if @institution_params[:assessment_question_responses]
        # delete existing AQRs
        @institution.assessment_question_responses.destroy_all
        # the AQR params from the form are not in a rails-compatible format
        @institution_params[:assessment_question_responses].each_value do |option_id|
          option = AssessmentQuestionOption.find(option_id)
          @institution.assessment_question_responses << AssessmentQuestionResponse.new(
              assessment_question_option: option,
              assessment_question: option.assessment_question)
        end
      end

      @institution.update!(@institution_params.except(:assessment_question_responses))
    rescue ActiveRecord::RecordInvalid
      @institution.events << Event.create(
          description: "Attempted to update institution "\
          "\"#{@institution.name},\" but failed: "\
          "#{@institution.errors.full_messages[0]}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to update institution \"#{@institution.name}\": "\
            "#{@institution.errors.full_messages[0]}"
    rescue => e
      @institution.events << Event.create(
          description: "Attempted to update institution "\
          "\"#{@institution.name},\" but failed: #{e.message}",
          user: @doing_user, address: @remote_ip,
          event_level: EventLevel::ERROR)
      raise "Failed to update institution \"#{@institution.name}\": #{e.message}"
    else
      @institution.events << Event.create(
          description: "Updated institution \"#{@institution.name}\"",
          user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @institution
  end

end
