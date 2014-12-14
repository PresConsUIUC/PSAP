class AssessmentSection < ActiveRecord::Base
  belongs_to :assessment, inverse_of: :assessment_sections
  has_many :assessment_questions, inverse_of: :assessment_section,
           dependent: :destroy
  has_and_belongs_to_many :events, join_table: 'events_assessment_sections'

  validates :assessment, presence: true
  validates :index, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates_uniqueness_of :name, scope: :assessment_id

  def assessment_questions_for_format(format)
    format ? format.all_assessment_questions.where(assessment_section: self) :
        AssessmentQuestion.where(id: 'cats') # empty set
  end

  def max_score
    score = 0
    self.assessment_questions.each do |question|
      max = question.assessment_question_options.map{ |o| o.value }.max
      score += max * question.weight if max
    end
    score
  end

end
