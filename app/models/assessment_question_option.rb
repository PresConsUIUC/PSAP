class AssessmentQuestionOption < ActiveRecord::Base
  belongs_to :assessment_question, inverse_of: :assessment_question_options
end
