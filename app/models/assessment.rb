class Assessment < ActiveRecord::Base
  has_one :resource, inverse_of: :assessment
  has_many :assessment_sections, inverse_of: :assessment, dependent: :destroy

  validates :key, presence: true, length: { maximum: 30 }
  validates :name, presence: true, length: { maximum: 255 }
  validates :percent_complete, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

end
