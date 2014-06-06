class AssessmentQuestion < ActiveRecord::Base
  belongs_to :assessment_section, inverse_of: :assessment_questions
  belongs_to :enabling_assessment_question_option,
             class_name: 'AssessmentQuestionOption',
             foreign_key: 'enabling_assessment_question_option_id',
             inverse_of: :dependent_assessment_question
  belongs_to :parent, class_name: 'AssessmentQuestion', inverse_of: :children
  has_and_belongs_to_many :events
  has_many :assessment_question_options, inverse_of: :assessment_question,
           dependent: :destroy
  has_many :assessment_question_responses,
           inverse_of: :assessment_question, dependent: :destroy
  has_many :children, class_name: 'AssessmentQuestion',
           foreign_key: 'parent_id', inverse_of: :parent, dependent: :destroy

  validates :assessment_section, presence: true
  validates :index, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :question_type, presence: true
  validates_numericality_of :weight, greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 1, presence: true

  accepts_nested_attributes_for :assessment_question_options,
                                allow_destroy: true

  def readable_question_type
    case question_type
      when AssessmentQuestionType::RADIO
        'Radio buttons'
      when AssessmentQuestionType::SELECT
        'Pull-down menu'
      when AssessmentQuestionType::CHECKBOX
        'Checkboxes'
    end
  end

end
