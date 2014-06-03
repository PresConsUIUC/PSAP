class AssessmentQuestionOption < ActiveRecord::Base
  belongs_to :assessment_question, inverse_of: :assessment_question_options
  has_many :assessment_question_responses,
           inverse_of: :assessment_question_option
  has_one :dependent_assessment_question,
          class_name: 'AssessmentQuestion',
          inverse_of: :enabling_assessment_question_option

  validates :assessment_question, presence: true
  validates :index, presence: true
  validates :name, presence: true
  validates :value, presence: true
end
