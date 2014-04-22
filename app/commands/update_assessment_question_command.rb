class UpdateAssessmentQuestionCommand < Command

  def initialize(assessment_question, assessment_question_params, user,
      remote_ip)
    @assessment_question = assessment_question
    @assessment_question_params = assessment_question_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    @assessment_question.update!(@assessment_question_params)
    Event.create(description: 'Updated assessment question',
                 user: @user, address: @remote_ip)
  end

  def object
    @assessment_question
  end

end
