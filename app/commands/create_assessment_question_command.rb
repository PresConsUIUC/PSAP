class CreateAssessmentQuestionCommand < Command

  def self.updateQuestionIndexes(assessment_question = nil)
    if assessment_question
      questions = AssessmentQuestion.where.not(id: assessment_question.id).
          where('"index" >= ?', assessment_question.index).order(:index)
      questions.each do |question|
        question.index = question.index + 1
        question.save!
      end
    else
      questions = AssessmentQuestion.order(:index)
      for i in 0..questions.length
        questions[i].index = i
        questions[i].save!
      end
    end
  end

  def initialize(assessment_question_params, user, remote_ip)
    @assessment_question_params = assessment_question_params
    @user = user
    @assessment_question = AssessmentQuestion.new(@assessment_question_params)
    @remote_ip = remote_ip
  end

  def execute
    if @assessment_question.index.blank?
      @assessment_question.index = 0
    else
      @assessment_question.index += 1
    end

    begin
      @assessment_question.save!
      CreateAssessmentQuestionCommand.updateQuestionIndexes(@assessment_question)
    rescue => e
      Event.create(description: "Failed to create assessment question: "\
      "#{e.message}",
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::FAILURE)
      raise e
    else
      Event.create(description: 'Created assessment question',
                   user: @user, address: @remote_ip,
                   event_status: EventStatus::SUCCESS)
    end
  end

  def object
    @assessment_question
  end

end
