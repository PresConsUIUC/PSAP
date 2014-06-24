module AssessmentQuestionsHelper

  def assessment_question_options_for_select
    questions = AssessmentQuestion.where(parent_id: nil).order(:index)
    values_for_select(questions)
  end

  private

  def values_for_select(questions, pairs = [], depth = 0)
    space = '&nbsp;&nbsp;&nbsp;&nbsp;' * depth
    questions.each do |question|
      pairs << [raw("#{space}#{question.name}"), question.id]
      if question.children.any?
        values_for_select(question.children.order(:index), pairs, depth + 1)
      end
    end
    pairs
  end

end
