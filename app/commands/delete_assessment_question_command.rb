class DeleteAssessmentQuestionCommand < Command

  def initialize(assessment_question, user, remote_ip)
    @assessment_question = assessment_question
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    begin
      @assessment_question.destroy!
      Event.create(description: 'Deleted assessment question',
                   user: @user, address: @remote_ip)
    rescue ActiveRecord::DeleteRestrictionError => e
      @assessment_question.errors.add(:base, e)
      raise e
    end
  end

  def object
    @assessment_question
  end

end
