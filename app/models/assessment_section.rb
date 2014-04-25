class AssessmentSection < ActiveRecord::Base
  belongs_to :assessment, inverse_of: :assessment_sections
  has_many :assessment_questions, inverse_of: :assessment_section,
           dependent: :destroy

  validates :assessment, presence: true
  validates :index, presence: true
  validates :name, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }

  def deep_clone
    obj = self.dup
    self.assessment_questions.each do |question|
      obj.assessment_questions << question.deep_clone
    end
    return obj
  end

end
