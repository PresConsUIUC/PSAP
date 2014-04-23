class UpdateAssessmentQuestionCommand < Command

  def initialize(assessment_question, assessment_question_params, user,
      remote_ip)
    @assessment_question = assessment_question
    @assessment_question_params = assessment_question_params
    @user = user
    @remote_ip = remote_ip
  end

  def execute
    if @assessment_question_params[:index].length == 0
      @assessment_question_params[:index] = '0'
    else
      @assessment_question_params[:index] =
          @assessment_question_params[:index].to_i + 1
    end

    @assessment_question.update!(@assessment_question_params)

    if @assessment_question.index != @assessment_question_params[:index]
      CreateAssessmentQuestionCommand.updateQuestionIndexes(
          @assessment_question)
    end

    Event.create(description: 'Updated assessment question',
                 user: @user, address: @remote_ip)
  end

  def object
    @assessment_question
  end

end
