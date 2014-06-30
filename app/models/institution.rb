class Institution < ActiveRecord::Base
  has_many :users, inverse_of: :institution, dependent: :restrict_with_exception
  has_many :repositories, inverse_of: :institution, dependent: :destroy
  has_and_belongs_to_many :events
  belongs_to :language, inverse_of: :institutions
  has_many :locations, through: :repositories
  has_many :resources, through: :locations

  validates :address1, presence: true, length: { maximum: 255 }
  validates :address2, length: { maximum: 255 }
  validates :city, presence: true, length: { maximum: 255 }
  validates :name, presence: true, length: { minimum: 4, maximum: 255 },
            uniqueness: { case_sensitive: false }
  validates :state, presence: true, length: { maximum: 30 }
  validates :postal_code, presence: true, length: { maximum: 30 }
  validates :country, presence: true, length: { maximum: 255 }
  validates :url, allow_blank: true, format: URI::regexp(%w(http https))

  def resources_as_csv
    # get a list of all questions
    questions = []
    Assessment.find_by_key('resource').assessment_sections.order(:index).each do |section|
      questions += section.assessment_questions
    end

    # find the max number of one-to-many columns needed
    num_columns = { creator: 0, date: 0, subject: 0, extent: 0, note: 0 }
    self.resources.each do |resource|
      num_columns[:creator] = [resource.creators.length, num_columns[:creator]].max
      num_columns[:date] = [resource.resource_dates.length, num_columns[:date]].max
      num_columns[:subject] = [resource.subjects.length, num_columns[:subject]].max
      num_columns[:extent] = [resource.extents.length, num_columns[:extent]].max
      num_columns[:note] = [resource.resource_notes.length, num_columns[:note]].max
    end

    # get a list of all question names (question text)
    question_names = questions.map{ |q| q.name }

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
          (['Creator'] * num_columns[:creator]) +
          (['Date'] * num_columns[:date]) +
          ['Language'] +
          (['Subject'] * num_columns[:subject]) +
          (['Extent'] * num_columns[:extent]) +
          ['Rights'] +
          ['Description'] +
          (['Note'] * num_columns[:note]) +
          ['Created'] +
          ['Updated'] +
          question_names
      self.resources.each do |resource|
        # get a list of all question response names (question response text)
        question_response_names = []
        questions.each_with_index do |question, index|
          response = resource.response_to_question(question)
          question_response_names << (response ? "Q#{index + 1}: #{response.assessment_question_option.name}" : nil)
        end

        # can't use Resource.as_csv because we need to pad the one-to-many
        # properties with blanks
        csv << [resource.local_identifier] +
            [resource.name] +
            [resource.assessment_score * 100] +
            [resource.readable_resource_type] +
            [resource.parent ? resource.parent.name : nil] +
            [resource.format ? resource.format.name : nil] +
            [resource.readable_significance] +
            resource.creators.map { |r| r.name } + [nil] * (num_columns[:creator] - resource.creators.length) +
            resource.resource_dates.map { |r| r.as_dublin_core_string } + [nil] * (num_columns[:date] - resource.resource_dates.length) +
            [resource.language ? resource.language.english_name : nil] +
            resource.subjects.map { |s| s.name } + [nil] * (num_columns[:subject] - resource.subjects.length) +
            resource.extents.map { |e| e.name } + [nil] * (num_columns[:extent] - resource.extents.length) +
            [resource.rights] +
            [resource.description] +
            resource.resource_notes.map { |n| n.value } + [nil] * (num_columns[:note] - resource.resource_notes.length) +
            [resource.created_at.iso8601] +
            [resource.updated_at.iso8601] +
            question_response_names
      end
    end
  end

end
