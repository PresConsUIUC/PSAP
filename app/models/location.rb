##
# A Location exists within a Repository. It can contain zero or more Resources.
#
# Locations are assessable.
#
class Location < ActiveRecord::Base

  include Assessable

  has_and_belongs_to_many :assessment_questions
  has_many :assessment_question_responses, inverse_of: :location,
           dependent: :destroy
  has_and_belongs_to_many :events
  belongs_to :repository, inverse_of: :locations
  has_many :resources, -> { order(:name) }, inverse_of: :location,
           dependent: :destroy

  accepts_nested_attributes_for :assessment_question_responses

  validates :name, presence: true, length: { maximum: 255 }
  validates :repository, presence: true

  validates_uniqueness_of :name, scope: :repository_id

  after_save :update_resource_assessment_scores

  ##
  # Used by `Repository.import()`.
  #
  # @param struct [Hash]
  # @param location_id [Integer]
  # @return [Location]
  #
  def self.import(struct, repository_id)
    loc = Location.create!(name: struct['name'],
                           description: struct['description'],
                           assessment_score: struct['assessment_score'],
                           assessment_complete: struct['assessment_complete'],
                           repository_id: repository_id,
                           created_at: struct['created_at'],
                           updated_at: struct['updated_at'])
    struct['assessment_question_responses'].each do |response|
      loc.assessment_question_responses.build(
          assessment_question_option_id: response['assessment_question_option_id'],
          assessment_question_id: response['assessment_question_id'],
          created_at: response['created_at'],
          updated_at: response['updated_at'])
    end
    struct['resources'].each do |resource|
      Resource.import(resource, loc.id)
    end
    loc.save!
    loc
  end

  ##
  # Exports all of an instance's associated content.
  #
  # @see `Institution.full_export_as_json()`
  # @return [Hash]
  #
  def full_export_as_json
    struct = self.as_json
    struct[:assessment_question_responses] =
        self.assessment_question_responses.map { |r| r.as_json }
    struct[:resources] = self.resources.map { |res| res.full_export_as_json }
    struct
  end

  def humidity_range
    response = self.response_to_question(AssessmentQuestion.find_by_qid(1024))
    if response
      values = response.assessment_question_option.name.gsub('–', '-').
          split('-').map{ |v| v.gsub(/\D/, '').to_i }
      if values.length == 2
        return HumidityRange.new(min_rh: values[0], max_rh: values[1])
      end
    end
    nil
  end

  def temperature_range
    response = self.response_to_question(AssessmentQuestion.find_by_qid(1022))
    if response
      values = response.assessment_question_option.name.gsub('–', '-').
          split('-').map{ |v| v.gsub(/\D/, '').to_i }
      if values.length == 2
        return TemperatureRange.new(min_temp_f: values[0], max_temp_f: values[1])
      end
    end
    nil
  end

  private

  ##
  # Updates the assessment scores of all resources contained within the
  # instance, since they are dependent upon the assessment score of the
  # instance.
  #
  def update_resource_assessment_scores
    # TODO: only do this if the location assessment has changed
    self.resources.select{ |r| r.assessment_complete }.each{ |r| r.save! }
  end

end
