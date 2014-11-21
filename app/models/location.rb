##
# A Location exists within a Repository. It can contain zero or more Resources.
#
class Location < ActiveRecord::Base

  include Assessable

  has_and_belongs_to_many :assessment_questions
  has_many :assessment_question_responses, inverse_of: :location,
           dependent: :destroy
  has_and_belongs_to_many :events
  belongs_to :repository, inverse_of: :locations
  has_many :resources, inverse_of: :location, dependent: :destroy
  belongs_to :temperature_range, inverse_of: :location, dependent: :destroy

  accepts_nested_attributes_for :assessment_question_responses
  accepts_nested_attributes_for :temperature_range

  validates :assessment_score, allow_blank: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :name, presence: true, length: { maximum: 255 }
  validates :repository, presence: true

  before_save :update_assessment_score # Assessable mixin

end
