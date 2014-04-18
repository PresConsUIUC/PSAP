class AssessmentQuestion < ActiveRecord::Base
  belongs_to :assessment_section, inverse_of: :assessment_questions
  has_many :assessment_question_options, inverse_of: :assessment_question,
           dependent: :destroy

  def readable_question_type
    case question_type
      when AssessmentQuestionType::RADIO
        'Radio buttons'
      when AssessmentQuestionType::SELECT
        'Pull-down menu'
      when AssessmentQuestionType::CHECKBOX
        'Checkboxes'
    end
  end
end
