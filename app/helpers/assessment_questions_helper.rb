module AssessmentQuestionsHelper

  SCORES = [
      {
          cutoff: 0.6666,
          bootstrap_bg_class: 'bg-success',
          bootstrap_fg_class: 'text-success',
          bootstrap_progress_bar_class: 'progress-bar-success',
          characterization: 'High'
      },
      {
          cutoff: 0.3333,
          bootstrap_bg_class: 'bg-warning',
          bootstrap_fg_class: 'text-warning',
          bootstrap_progress_bar_class: 'progress-bar-warning',
          characterization: 'Moderate'
      },
      {
          cutoff: 0,
          bootstrap_bg_class: 'bg-danger',
          bootstrap_fg_class: 'text-danger',
          bootstrap_progress_bar_class: 'progress-bar-danger',
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

  def bootstrap_progress_bar_class_for_score(score)
    SCORES.each do |s|
      if s[:cutoff] <= score
        return s[:bootstrap_progress_bar_class]
      end
    end
    ''
  end

  def hex_color_for_score(score)
    # 10-stop gradient from red -> orange -> green
    # these should be kept in sync with institutions.css.scss
    colors = %w(d00000 d00000 d42800 d85000 dc7800 e0a000 aba000 70a000 38a000 00a000)
    colors.each_with_index do |color, index|
      return color if index.to_f * 0.1 >= score
    end
    '000000'
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
