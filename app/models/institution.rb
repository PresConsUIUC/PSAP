class Institution < ActiveRecord::Base

  include Assessable

  has_and_belongs_to_many :assessment_questions
  has_many :assessment_question_responses, inverse_of: :institution,
           dependent: :destroy
  has_many :desiring_users, class_name: 'User', inverse_of: :desired_institution,
           dependent: :restrict_with_exception
  has_many :users, inverse_of: :institution, dependent: :restrict_with_exception
  has_many :repositories, inverse_of: :institution, dependent: :destroy
  has_and_belongs_to_many :events
  belongs_to :language, inverse_of: :institutions
  has_many :locations, through: :repositories
  has_many :resources, through: :locations

  accepts_nested_attributes_for :assessment_question_responses

  validates :address1, presence: true, length: { maximum: 255 }
  validates :address2, length: { maximum: 255 }
  validates :assessment_score, allow_blank: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :city, presence: true, length: { maximum: 255 }
  validates :name, presence: true, length: { minimum: 4, maximum: 255 },
            uniqueness: { case_sensitive: false }
  validates :state, presence: true, length: { maximum: 30 }
  validates :postal_code, presence: true, length: { maximum: 30 }
  validates :country, presence: true, length: { maximum: 255 }
  validates :url, allow_blank: true, format: URI::regexp(%w(http https))

  before_save :update_assessment_score # Assessable mixin

  ##
  # Returns a list of "most active" institutions based on the number of
  # resources their users have created/updated.
  #
  # @return Array of hashes containing :count and :institution keys
  #
  def self.most_active(limit = 5)
    sql = "SELECT COUNT(description) AS count, users.institution_id AS institution_id "\
          "FROM users "\
          "LEFT JOIN events_users ON users.id = events_users.user_id "\
          "LEFT JOIN events ON events_users.event_id = events.id "\
          "WHERE events.description LIKE 'Created resource%' "\
            "OR events.description LIKE 'Updated resource%' "\
          "GROUP BY institution_id "\
          "ORDER BY count DESC "\
          "LIMIT #{limit}"
    connection = ActiveRecord::Base.connection
    counts = connection.execute(sql)

    counts.map{ |r| { count: r['count'].to_i,
                      institution: Institution.find(r['institution_id']) } }
  end

  ##
  # @return Array of all assessed items in an institution, regardless of depth
  # in the hierarchy.
  #
  def all_assessed_items
    self.resources.select{ |x| x.assessment_percent_complete >= 0.999999 }
  end

  ##
  # Returns a hash containing statistics of all assessed items in the
  # institution.
  #
  # @return hash with mean, median, low, and high keys
  #
  def assessed_item_statistics
    stats = { mean: 0, median: 0, low: 0, high: 0 }
    all_items = all_assessed_items
    if all_items.length < 1
      return stats
    end

    all_items.each do |item|
      stats[:high] = item.total_assessment_score if item.total_assessment_score > stats[:high]
      stats[:low] = item.total_assessment_score if
          stats[:low].nil? or item.total_assessment_score < stats[:low]
    end
    stats[:mean] = all_items.map{ |r| r.total_assessment_score }.sum.to_f / all_items.length.to_f
    sorted = all_items.map{ |r| r.total_assessment_score }.sort
    len = sorted.length
    stats[:median] = (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    stats
  end

  ##
  # Returns a list of the "most active" users in the institution, based on the
  # number of resources they've created/updated.
  #
  # @return Array of hashes containing :count and :user keys
  #
  def most_active_users(limit = 5)
    sql = "SELECT COUNT(description) AS count, users.id AS user_id "\
          "FROM users "\
          "LEFT JOIN events_users ON users.id = events_users.user_id "\
          "LEFT JOIN events ON events_users.event_id = events.id "\
          "WHERE (events.description LIKE 'Created resource%' "\
              "OR events.description LIKE 'Updated resource%') "\
            "AND users.institution_id = #{self.id} "\
          "GROUP BY users.id "\
          "ORDER BY count DESC "\
          "LIMIT #{limit}" # TODO: is the GROUP BY right?
    connection = ActiveRecord::Base.connection
    counts = connection.execute(sql)

    results = []
    counts.each do |row|
      results << { count: row['count'].to_i,
                   user: User.find(row['user_id']) } if row['user_id']
    end
    results
  end

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
            [resource.total_assessment_score * 100] +
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
