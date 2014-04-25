class Assessment < ActiveRecord::Base
  has_one :resource, inverse_of: :assessment
  has_many :assessment_sections, inverse_of: :assessment, dependent: :destroy

  validates :key, presence: true, length: { maximum: 30 }
  validates :name, presence: true, length: { maximum: 255 }
  validates :percent_complete, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  def to_param
    key
  end

  def deep_clone
    obj = self.dup
    obj.is_template = false
    self.assessment_sections.each do |section|
      obj.assessment_sections << section.deep_clone
    end
    return obj
  end

end
