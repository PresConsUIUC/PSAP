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
  has_and_belongs_to_many :events
  belongs_to :format, inverse_of: :resources
  belongs_to :language, inverse_of: :resources
  belongs_to :location, inverse_of: :resources
  belongs_to :parent, class_name: 'Resource', inverse_of: :children
  belongs_to :user, inverse_of: :resources

  accepts_nested_attributes_for :assessment_question_responses
  accepts_nested_attributes_for :creators, allow_destroy: true
  accepts_nested_attributes_for :extents, allow_destroy: true
  accepts_nested_attributes_for :resource_dates, allow_destroy: true
  accepts_nested_attributes_for :resource_notes, allow_destroy: true
  accepts_nested_attributes_for :subjects, allow_destroy: true

  validates :assessment_percent_complete, allow_blank: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :assessment_score, allow_blank: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :location, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :resource_type, presence: true
  validates :user, presence: true

  validates_inclusion_of :significance, in: [0, 0.5, 1], allow_nil: true

  before_save :update_assessment_percent_complete, :update_assessment_score

  def as_csv
    # TODO: write this
    require 'csv'
    # CSV format is defined in G:|AcqCatPres\PSAP\Design\CSV
    CSV.generate do |csv|
      csv << ['Local Identifier'] +
          ['Title/Name'] +
          ['PSAP Assessment Score'] +
          ['Resource Type'] +
          ['Parent Resource'] +
          ['Format'] +
          ['Significance'] +
          (['Creator'] * self.creators.length) +
          (['Date'] * self.resource_dates.length) +
          ['Language'] +
          (['Subject'] * self.subjects.length) +
          (['Extent'] * self.extents.length) +
          ['Rights'] +
          ['Description'] +
          (['Note'] * self.resource_notes.length) +
          ['Created'] +
          ['Updated']
          # TODO: questions
      csv << [self.local_identifier] +
          [self.name] +
          [self.assessment_score * 100] +
          [self.readable_resource_type] +
          [self.parent ? self.parent.title : nil] +
          [self.format.name] +
          [self.readable_significance] +
          self.creators.map { |r| r.name } +
          self.resource_dates.map { |r| r.as_dublin_core_string } +
          [self.language ? self.language.english_name : nil] +
          self.subjects.map { |s| s.name } +
          self.extents.map { |e| e.name } +
          [self.rights] +
          [self.description] +
          self.resource_notes.map { |n| n.value } +
          [self.created_at.iso8601] +
          [self.updated_at.iso8601]
    end
  end

  def associate_assessment_question_responses
    Assessment.find_by_key('resource').assessment_sections.order(:index).
        each do |section|
      section.assessment_questions.each do |question|
        unless self.assessment_question_responses.
            select { |r| r.assessment_question == question }.any?
          self.assessment_question_responses <<
              AssessmentQuestionResponse.new(assessment_question: question)
        end
      end
    end
  end

  def update_assessment_percent_complete
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

      self.assessment_percent_complete = questions.length > 0 ?
          responses.length.to_f / questions.length : 0
  end

  def update_assessment_score
    # TODO: write this
    self.assessment_score = 0
  end

  # TODO: get rid of these filename methods
  def csv_filename
    "#{filename_minus_extension}.txt"
  end

  def dcxml_filename
    "#{filename_minus_extension}.xml"
  end

  def ead_filename
    "#{filename_minus_extension}.xml"
  end

  def readable_resource_type
    case resource_type
      when ResourceType::COLLECTION
        'Collection'
      when ResourceType::ITEM
        'Item'
    end
  end

  def readable_significance
    case significance
      when ResourceSignificance::LOW
        'Low'
      when ResourceSignificance::MODERATE
        'Moderate'
      when ResourceSignificance::HIGH
        'High'
    end
  end

  private

  def filename_minus_extension
    self.local_identifier ? self.local_identifier : self.id
  end

end
