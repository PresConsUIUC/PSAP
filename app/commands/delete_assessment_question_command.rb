class DeleteAssessmentQuestionCommand < Command

  def initialize(assessment_question, doing_user, remote_ip)
    @assessment_question = assessment_question
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      ActiveRecord::Base.transaction do
        @assessment_question.destroy!
        CreateAssessmentQuestionCommand.updateQuestionIndexes
      end
    rescue ActiveRecord::DeleteRestrictionError => e
      raise e # this should never happen
    rescue => e
      Event.create(description: "Attempted to delete an assessment question, "\
      "but failed: #{e.message}",
                   user: @doing_user, address: @remote_ip,
                   event_level: EventLevel::ERROR)
      raise "Failed to delete assessment question: #{e.message}"
    else
      Event.create(description: 'Deleted assessment question',
                   user: @doing_user, address: @remote_ip)
    end
  end

  def object
    @assessment_question
  end

end
