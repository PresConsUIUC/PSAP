class DeleteAssessmentQuestionCommand < Command

  def initialize(assessment_question, user, remote_ip)
    @assessment_question = assessment_question
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      ActiveRecord::Base.transaction do
        @assessment_question.destroy!
        CreateAssessmentQuestionCommand.updateQuestionIndexes
      end
    rescue ActiveRecord::DeleteRestrictionError => e
      Event.create(description: "Failed to delete assessment question: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::DEBUG)
      raise e
    rescue => e
      Event.create(description: "Failed to delete assessment question: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise e
    else
      Event.create(description: 'Deleted assessment question',
                   user: @user, address: @remote_ip)
    end
  end

  def object
    @assessment_question
  end

end
