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
  has_many :resources, -> { order(:name) }, inverse_of: :location,
           dependent: :destroy

  accepts_nested_attributes_for :assessment_question_responses

  validates :name, presence: true, length: { maximum: 255 }
  validates :repository, presence: true

end
