##
# A section of an assessment, such as "Use | Access", "Storage | Container",
# etc. An assessment section contains zero or more assessment questions and an
# "index" property to establish its order of appearance in the assessment form.
#
class AssessmentSection < ApplicationRecord

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
        AssessmentQuestion.none
  end

  def max_score(resource = nil)
    if resource and resource.kind_of?(Resource) and resource.format
      return self.assessment_questions_for_format(resource.format).
          map{ |q| q.max_score * q.weight }.reduce(:+)
    end
    self.assessment_questions.map{ |q| q.max_score * q.weight }.reduce(:+)
  end

end
