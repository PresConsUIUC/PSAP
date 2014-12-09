class AssessmentQuestionOption < ActiveRecord::Base
  belongs_to :assessment_question, inverse_of: :assessment_question_options
  has_many :assessment_question_responses,
           inverse_of: :assessment_question_option, dependent: :destroy
  has_and_belongs_to_many :dependent_assessment_questions,
          class_name: 'AssessmentQuestion'

  validates :assessment_question, presence: true
  validates :index, presence: true
  validates :name, presence: true
  validates :value, presence: true
end

