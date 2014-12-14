module AssessmentQuestionsHelper

  SCORES = [
      {
          cutoff: 0.6666,
          bootstrap_bg_class: 'bg-success',
          bootstrap_fg_class: 'text-success',
          characterization: 'High'
      },
      {
          cutoff: 0.3333,
          bootstrap_bg_class: 'bg-warning',
          bootstrap_fg_class: 'text-warning',
          characterization: 'Moderate'
      },
      {
          cutoff: 0,
          bootstrap_bg_class: 'bg-danger',
          bootstrap_fg_class: 'text-danger',
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

  def bootstrap_bg_class_for_score(score)
    SCORES.each do |s|
      if s[:cutoff] <= score
        return s[:bootstrap_bg_class]
      end
    end
    ''
  end

  def bootstrap_fg_class_for_score(score)
    SCORES.each do |s|
      if s[:cutoff] <= score
        return s[:bootstrap_fg_class]
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
