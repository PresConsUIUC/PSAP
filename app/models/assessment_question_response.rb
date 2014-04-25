class AssessmentQuestionResponse < ActiveRecord::Base
  belongs_to :assessment_question_option,
             inverse_of: :assessment_question_responses
  belongs_to :resource, inverse_of: :assessment_question_responses

  validates :assessment_question_option, presence: true
  validates :resource, presence: true
end
