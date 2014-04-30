class AssessmentSection < ActiveRecord::Base
  belongs_to :assessment, inverse_of: :assessment_sections
  has_many :assessment_questions, inverse_of: :assessment_section,
           dependent: :destroy

  validates :assessment, presence: true
  validates :index, presence: true
  validates :name, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }
  validates_numericality_of :weight, greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 1, presence: true

end
