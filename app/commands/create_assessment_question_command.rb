class CreateAssessmentQuestionCommand < Command

  def initialize(assessment_question_params, user, remote_ip)
    @assessment_question_params = assessment_question_params
    @user = user
    @assessment_question = AssessmentQuestion.new(@assessment_question_params)
    @remote_ip = remote_ip
  end

  def execute
    @assessment_question.save!
    Event.create(description: 'Created assessment question',
                 user: @user, address: @remote_ip)
  end

  def object
    @assessment_question
  end

end
