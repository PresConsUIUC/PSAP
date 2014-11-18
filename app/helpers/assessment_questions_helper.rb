module AssessmentQuestionsHelper

  SCORES = [
      {
          cutoff: 0.6666,
          bootstrap_class: 'bg-success',
          characterization: 'High'
      },
      {
          cutoff: 0.3333,
          bootstrap_class: 'bg-warning',
          characterization: 'Moderate'
      },
      {
          cutoff: 0,
          bootstrap_class: 'bg-danger',
          characterization: 'Low'
      },
  ]

  def assessment_question_options_for_select
    questions = AssessmentQuestion.where(parent_id: nil).order(:index)
    values_for_select(questions)
  end

  ##
  # @param score float
  # @return Human-readable characterization of the score, e.g. "High," "Low,"
  # etc.
  def assessment_score_characterization(score)
    SCORES.each do |s|
      if s[:cutoff] <= score
        return s[:characterization]
      end
    end
    'Unknown'
  end

  def bootstrap_class_for_section_score(score)
    SCORES.each do |s|
      if s[:cutoff] <= score
        return s[:bootstrap_class]
      end
    end
    ''
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
