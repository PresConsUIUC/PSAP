class AssessmentQuestionResponse < ActiveRecord::Base
  belongs_to :assessment_question,
             inverse_of: :assessment_question_responses
  belongs_to :assessment_question_option,
             inverse_of: :assessment_question_responses
  belongs_to :location, inverse_of: :assessment_question_responses
  belongs_to :resource, inverse_of: :assessment_question_responses

  validates :assessment_question, presence: true

  validate :validates_belongs_to_entity

  private

  def validates_belongs_to_entity
    if !location and !resource # TODO if !location and !institution and !resource
      errors[:base] << ('Assessment question response must belong to an entity.')
    end
  end

end
