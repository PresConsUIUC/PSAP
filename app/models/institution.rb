class Institution < ActiveRecord::Base

  include Assessable

  has_and_belongs_to_many :assessment_questions
  has_many :assessment_question_responses, inverse_of: :institution,
           dependent: :destroy
  has_many :desiring_users, class_name: 'User', inverse_of: :desired_institution,
           dependent: :restrict_with_exception
  has_many :users, -> { order(:last_name) }, inverse_of: :institution,
           dependent: :restrict_with_exception
  has_many :repositories, -> { order(:name) }, inverse_of: :institution,
           dependent: :destroy
  has_and_belongs_to_many :events
  belongs_to :language, inverse_of: :institutions
  has_many :locations, -> { order(:name) }, through: :repositories
  has_many :resources, -> { order(:name) }, through: :locations

  accepts_nested_attributes_for :assessment_question_responses

  validates :address1, presence: true, length: { maximum: 255 }
  validates :address2, length: { maximum: 255 }
  validates :city, presence: true, length: { maximum: 255 }
  validates :name, presence: true, length: { minimum: 4, maximum: 255 },
            uniqueness: { case_sensitive: false }
  validates :state, length: { maximum: 30 }
  validates :postal_code, length: { maximum: 30 }
  validates :country, presence: true, length: { maximum: 255 }
  validates :url, allow_blank: true, format: URI::regexp(%w(http https))

  ##
  # Returns a list of "most active" institutions based on the number of
  # resources their users have created/updated.
  #
  # @return Array of hashes containing :count and :institution keys
  #
  def self.most_active(limit = 5)
    sql = "SELECT COUNT(events.description) AS count, "\
            "users.institution_id AS institution_id "\
          "FROM users "\
          "LEFT JOIN events_users ON users.id = events_users.user_id "\
          "LEFT JOIN events ON ("\
            "events_users.event_id = events.id "\
            "AND events.description LIKE 'Created resource%' "\
              "OR events.description LIKE 'Updated resource%' "\
              "OR events.description LIKE 'Moved resource%') "\
          "WHERE users.institution_id IS NOT NULL "\
          "GROUP BY institution_id "\
          "ORDER BY count DESC "\
          "LIMIT #{limit}"
    connection = ActiveRecord::Base.connection
    counts = connection.execute(sql)

    counts.map{ |row| { count: row['count'].to_i,
                        institution: Institution.find(row['institution_id']) } }
  end

  ##
  # @return Array of all assessed items in an institution, regardless of depth
  # in the hierarchy.
  #
  def all_assessed_items
    self.resources.where(assessment_complete: true)
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
      stats[:high] = item.effective_assessment_score if item.effective_assessment_score > stats[:high]
      stats[:low] = item.effective_assessment_score if
          stats[:low].nil? or item.effective_assessment_score < stats[:low]
    end
    stats[:mean] = all_items.map{ |r| r.effective_assessment_score }.sum.to_f / all_items.length.to_f
    sorted = all_items.map{ |r| r.effective_assessment_score }.sort
    len = sorted.length
    stats[:median] = (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    stats
  end

  ##
  # @return Array of all assessed locations in an institution.
  #
  def assessed_locations
    self.locations.where(assessment_complete: true)
  end

  ##
  # @param section AssessmentSection
  # @return float
  #
  def mean_assessed_item_score_in_section(section)
    score = 0.0
    assessed_items = all_assessed_items
    return score if assessed_items.length < 1

    assessed_items.each do |item|
      score += item.assessment_score_in_section(section)
    end
    score.to_f / assessed_items.length.to_f
  end

  ##
  # @param section AssessmentSection
  # @return float
  #
  def mean_assessed_location_score_in_section(section)
    score = 0.0
    assessed_locations = self.assessed_locations
    return score if assessed_locations.length < 1

    assessed_locations.each do |location|
      score += location.assessment_score_in_section(section)
    end
    score / assessed_locations.length.to_f
  end

  def mean_location_score
    locations_ = locations.where(assessment_complete: true)
    locations_.any? ?
        locations_.map(&:assessment_score).reduce(:+).to_f / locations_.length.to_f :
        0.0
  end

  def mean_resource_score
    items = resources.where(resource_type: ResourceType::ITEM,
                            assessment_complete: true)
    items.any? ?
        items.map(&:assessment_score).reduce(:+).to_f / items.length.to_f : 0.0
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
          "LEFT JOIN events ON ("\
            "events_users.event_id = events.id "\
            "AND events.description LIKE 'Created resource%' "\
              "OR events.description LIKE 'Updated resource%' "\
              "OR events.description LIKE 'Moved resource%') "\
          "WHERE users.institution_id = #{self.id} "\
          "GROUP BY users.id "\
          "ORDER BY count DESC "\
          "LIMIT #{limit}"
    connection = ActiveRecord::Base.connection
    counts = connection.execute(sql)

    counts.map{ |row| { count: row['count'].to_i,
                        user: User.find(row['user_id']) } }
  end

end
