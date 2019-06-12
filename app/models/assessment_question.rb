class AssessmentQuestion < ApplicationRecord

  class Type
    RADIO = 0
    CHECKBOX = 1

    def self.all
      (0..1)
    end
  end

  belongs_to :assessment_section, inverse_of: :assessment_questions
  belongs_to :parent, class_name: 'AssessmentQuestion', inverse_of: :children,
             optional: true
  has_and_belongs_to_many :enabling_assessment_question_options,
                          class_name: 'AssessmentQuestionOption'
  has_and_belongs_to_many :events, join_table: 'events_assessment_questions'
  has_and_belongs_to_many :formats
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :institutions
  has_many :assessment_question_options, -> { order(:index) },
           inverse_of: :assessment_question, dependent: :destroy
  has_many :assessment_question_responses,
           inverse_of: :assessment_question, dependent: :destroy
  has_many :children, class_name: 'AssessmentQuestion',
           foreign_key: 'parent_id', inverse_of: :parent, dependent: :destroy

  validates :assessment_section, presence: true
  validates :index, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :qid, presence: true
  validates :question_type, presence: true,
            inclusion: { in: AssessmentQuestion::Type.all,
                         message: 'Must be a valid assessment question type.' }
  validates_numericality_of :weight, greater_than_or_equal_to: 0, presence: true

  accepts_nested_attributes_for :assessment_question_options,
                                allow_destroy: true

  def max_score
    #self.assessment_question_options.map(&:value).max
    1
  end

end
