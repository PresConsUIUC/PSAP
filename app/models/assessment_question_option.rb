class AssessmentQuestionOption < ActiveRecord::Base
  belongs_to :assessment_question, inverse_of: :assessment_question_options
  has_many :assessment_question_responses,
           inverse_of: :assessment_question_option

  validates :assessment_question, presence: true
end
