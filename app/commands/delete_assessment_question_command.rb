class DeleteAssessmentQuestionCommand < Command

  def initialize(assessment_question, user, remote_ip)
    @assessment_question = assessment_question
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @assessment_question.destroy!
      CreateAssessmentQuestionCommand.updateQuestionIndexes
    rescue ActiveRecord::DeleteRestrictionError => e
      @assessment_question.errors.add(:base, e)
      Event.create(description: "Failed to delete assessment question: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    rescue => e
      Event.create(description: "Failed to delete assessment question: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: 'Deleted assessment question',
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @assessment_question
  end

end
