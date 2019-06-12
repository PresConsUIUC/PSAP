##
# An institution is a top-level entity containing zero or more Repositories.
# Once assigned to an institution, users (except administrators) are restricted
# to accessing entities related to that institution.
#
# Institutions are assessable.
#
class Institution < ApplicationRecord

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
  belongs_to :language, inverse_of: :institutions, optional: true
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
  # Imports data exported from `full_export_as_json()`. All existing associated
  # data (except users and events) is deleted first.
  #
  # @param struct [Hash]
  # @return [void]
  #
  def self.import(struct)
    ActiveRecord::Base.transaction do
      # Destroy most of the institution's content (except users & events) in
      # order to make way for the imported content.
      inst = Institution.find(struct['id'].to_i)
      inst.assessment_question_responses.destroy_all
      inst.repositories.destroy_all

      struct['assessment_question_responses'].each do |response|
        inst.assessment_question_responses.build(
            assessment_question_option_id: response['assessment_question_option_id'],
            assessment_question_id: response['assessment_question_id'],
            created_at: response['created_at'],
            updated_at: response['updated_at'])
      end
      struct['repositories'].each do |repo|
        Repository.import(repo, inst.id)
      end
      inst.save!
      inst
    end
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
  # Exports all of an instance's associated content, except users, to enable
  # recovery of user-deleted data. To do this:
  #
  # 1. Stand up a second instance of the application
  # 2. Load its database with backup data
  # 3. Invoke this method and capture the return value (typically via a rake
  #    task)
  # 4. Pass the returned JSON to `import()` (typically via a rake task) on the
  #    production application instance
  #
  # @return [Hash] Hash that can be passed to JSON.generate()
  #
  def full_export_as_json
    struct = self.as_json
    struct[:assessment_question_responses] =
        self.assessment_question_responses.map { |r| r.as_json }
    struct[:repositories] = self.repositories.map { |repo| repo.full_export_as_json }
    struct
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
    items = resources.where(resource_type: Resource::Type::ITEM,
                            assessment_complete: true)
    items.any? ?
        items.map(&:assessment_score).reduce(:+).to_f / items.length.to_f : 0.0
  end

  def to_s
    "#{self.name}"
  end

end
