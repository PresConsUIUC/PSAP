class Assessment < ActiveRecord::Base
  has_many :assessment_sections, inverse_of: :assessment, dependent: :destroy
  has_and_belongs_to_many :events

  validates :key, presence: true, length: { maximum: 30 }
  validates :name, presence: true, length: { maximum: 255 }

  def to_param
    key
  end

  def readonly?
    !new_record?
  end

  def question_count
    count = 0
    self.assessment_sections.select{ |s|
      count += s.assessment_questions.length }
    count
  end

end
