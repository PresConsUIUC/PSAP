class UpdateAssessmentQuestionCommand < Command

  def initialize(assessment_question, assessment_question_params, doing_user,
      remote_ip)
    @assessment_question = assessment_question
    @assessment_question_params = assessment_question_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      ActiveRecord::Base.transaction do
        @assessment_question.update!(@assessment_question_params)
        if @assessment_question.index != @assessment_question_params[:index]
          CreateAssessmentQuestionCommand.updateQuestionIndexes(
              @assessment_question)
        end
      end
    rescue ActiveRecord::RecordInvalid
      Event.create(description: "Attempted to update assessment question, "\
      "but failed: #{@assessment_question.errors.full_messages[0]}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise ValidationError,
            "Failed to update assessment question: "\
            "#{@assessment_question.errors.full_messages[0]}"
    rescue => e
      Event.create(description: "Attempted to update assessment question, "\
      "but failed: #{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to update assessment question: #{e.message}"
    else
      Event.create(description: 'Updated assessment question',
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @assessment_question
  end

end
