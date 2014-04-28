class AssessmentQuestion < ActiveRecord::Base
  belongs_to :assessment_section, inverse_of: :assessment_questions
  belongs_to :parent, class_name: 'AssessmentQuestion', inverse_of: :children
  has_many :assessment_question_options, inverse_of: :assessment_question,
           dependent: :destroy
  has_many :assessment_question_responses,
           inverse_of: :assessment_question_response, dependent: :destroy
  has_many :children, class_name: 'AssessmentQuestion',
           foreign_key: 'parent_id', inverse_of: :parent, dependent: :destroy

  validates :assessment_section, presence: true
  validates :index, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :question_type, presence: true
  validates :weight, presence: true

  accepts_nested_attributes_for :assessment_question_options

  after_initialize :setup, if: :new_record?

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

  def setup
    self.assessment_question_options << AssessmentQuestionOption.new(
        name: 'Sample Option', index: 0, value: 1, assessment_question: self)
  end

end
