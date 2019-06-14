class UpdateResourceCommand < Command

  def initialize(resource, resource_params, doing_user, remote_ip)
    @resource = resource
    @resource_params = resource_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      # Fail if a non-admin user is trying to update a resource in a
      # different institution
      if @doing_user and !@doing_user.is_admin? and
          @doing_user.institution != @resource.location.repository.institution
        raise 'Insufficient privileges'
      end

      if @resource_params[:assessment_question_responses]
        # delete existing AQRs
        @resource.assessment_question_responses.destroy_all
        # the AQR params from the form are not in a rails-compatible format
        @resource_params[:assessment_question_responses].each_pair do |k, option_id|
          option = AssessmentQuestionOption.find(option_id)
          @resource.assessment_question_responses << AssessmentQuestionResponse.new(
              assessment_question_option: option,
              assessment_question: option.assessment_question)
        end
      end

      @resource.update!(@resource_params.except(:assessment_question_responses))
    rescue ActiveRecord::RecordInvalid
      raise ValidationError,
            "Failed to update resource \"#{@resource.name}\": "\
            "#{@resource.errors.full_messages[0]}"
    rescue => e
      raise "Failed to update resource \"#{@resource.name}\": #{e.message}"
    end
  end

  def object
    @resource
  end

end
