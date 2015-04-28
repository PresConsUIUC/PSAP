##
# Top-level read-only entity containing an entity assessment. There are three
# seeded in the database, corresponding to the institution, location, and
# resource assessments, identifiable by the "key" property.
#
class Assessment < ActiveRecord::Base
  has_many :assessment_questions, through: :assessment_sections
  has_many :assessment_sections, -> { order(:index) },
           inverse_of: :assessment, dependent: :destroy

  validates :key, presence: true, length: { maximum: 30 }
  validates :name, presence: true, length: { maximum: 255 } # TODO: this is never used

  def to_param
    key
  end

  def readonly?
    !new_record?
  end

end
