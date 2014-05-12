class Resource < ActiveRecord::Base
  has_many :assessment_question_responses, inverse_of: :resource,
           dependent: :destroy
  has_many :children, class_name: 'Resource', foreign_key: 'parent_id',
           inverse_of: :parent, dependent: :destroy
  has_many :creators, inverse_of: :resource, dependent: :destroy
  has_many :extents, inverse_of: :resource, dependent: :destroy
  has_many :resource_dates, inverse_of: :resource, dependent: :destroy
  has_many :resource_notes, inverse_of: :resource, dependent: :destroy
  has_many :subjects, inverse_of: :resource, dependent: :destroy
  belongs_to :format, inverse_of: :resources
  belongs_to :location, inverse_of: :resources
  belongs_to :parent, class_name: 'Resource', inverse_of: :children
  belongs_to :user, inverse_of: :resources

  accepts_nested_attributes_for :assessment_question_responses
  accepts_nested_attributes_for :creators, allow_destroy: true
  accepts_nested_attributes_for :extents, allow_destroy: true
  accepts_nested_attributes_for :resource_dates, allow_destroy: true
  accepts_nested_attributes_for :resource_notes, allow_destroy: true
  accepts_nested_attributes_for :subjects, allow_destroy: true

  validates :location, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :resource_type, presence: true
  validates :user, presence: true

  def assessment_percent_complete
    unless @assessment_percent_complete
      # SELECT assessment_questions.id
      # FROM assessment_questions
      # LEFT JOIN assessment_sections
      #     ON assessment_questions.assessment_section_id = assessment_sections.id
      # LEFT JOIN assessments
      #     ON assessment_sections.assessment_id = assessments.id
      # WHERE assessments.key = 'resource'
      questions = AssessmentQuestion.
          select('assessment_questions.id').
          joins('LEFT JOIN assessment_sections '\
            'ON assessment_questions.assessment_section_id = assessment_sections.id').
          joins('LEFT JOIN assessments '\
            'ON assessment_sections.assessment_id = assessments.id').
          where('assessments.key = \'resource\'')

      # SELECT assessment_question_responses.id
      # FROM assessment_question_responses
      # LEFT JOIN assessment_question_options
      #     ON assessment_question_options.id = assessment_question_responses.assessment_question_option_id
      # WHERE assessment_question_responses.resource_id = ?
      #     AND assessment_question_responses.assessment_question_option_id IS NOT NULL
      # GROUP BY assessment_question_options.assessment_question_id
      responses = AssessmentQuestionResponse.
          select('assessment_question_responses.id').
          joins('LEFT JOIN assessment_question_options '\
            'ON assessment_question_options.id '\
              '= assessment_question_responses.assessment_question_option_id').
          where('assessment_question_responses.resource_id = ?', self.id).
          where('assessment_question_responses.assessment_question_option_id IS NOT NULL').
          group('assessment_question_options.assessment_question_id')

      @assessment_percent_complete = questions.length > 0 ?
          responses.length.to_f / questions.length : 0
    end
    @assessment_percent_complete
  end

  def dcxml_filename
    self.local_identifier ? "#{self.local_identifier}.xml" : "#{self.id}.xml"
  end

  def ead_filename
    self.local_identifier ? "#{self.local_identifier}.xml" : "#{self.id}.xml"
  end

  def readable_resource_type
    case resource_type
      when ResourceType::COLLECTION
        'Collection'
      when ResourceType::ITEM
        'Item'
    end
  end

end
