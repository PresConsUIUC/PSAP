class UpdateLocationCommand < Command

  def initialize(location, location_params, doing_user, remote_ip)
    @location = location
    @location_params = location_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      # Fail if a non-admin user is trying to update a location in a
      # different institution
      if @doing_user and !@doing_user.is_admin? and
          @doing_user.institution != @location.repository.institution
        raise 'Insufficient privileges'
      end

      if @location_params[:assessment_question_responses]
        # delete existing AQRs
        @location.assessment_question_responses.destroy_all
        # the AQR params from the form are not in a rails-compatible format
        @location_params[:assessment_question_responses].each_pair do |k, option_id|
          option = AssessmentQuestionOption.find(option_id)
          @location.assessment_question_responses << AssessmentQuestionResponse.new(
              assessment_question_option: option,
              assessment_question: option.assessment_question)
        end
      end

      @location.update!(@location_params.except(:assessment_question_responses))
    rescue ActiveRecord::RecordInvalid
      raise ValidationError,
            "Failed to update location \"#{@location.name}\": "\
            "#{@location.errors.full_messages[0]}"
    rescue => e
      raise "Failed to update location \"#{@location.name}\": #{e.message}"
    end
  end

  def object
    @location
  end

end
