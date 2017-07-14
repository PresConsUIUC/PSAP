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

  ##
  # Returns an Enumerable of children using an SQL self-join. Faster than
  # navigating the adjacency list in Ruby, but produces output that is harder
  # to work with.
  #
  # @return [Enumerable<Hash<String,String>]
  # @see Resource.children_as_tree()
  #
  def resources_as_tree
    sql = "SELECT\n"
    Resource::MAX_TREE_LEVELS.times do |i|
      sql += "  t#{i}.id AS lv#{i}_id,
    t#{i}.name AS lv#{i}_name,
    t#{i}.assessment_complete AS lv#{i}_assessment_complete,
    t#{i}.resource_type AS lv#{i}_resource_type"
      sql += "," if i < Resource::MAX_TREE_LEVELS - 1
      sql += "\n"
    end
    sql += "FROM resources AS t0\n"
    Resource::MAX_TREE_LEVELS.times do |i|
      sql += "LEFT JOIN resources AS t#{i + 1} ON t#{i + 1}.parent_id = t#{i}.id\n"
    end
    sql += "LEFT JOIN locations ON locations.id = t0.location_id\n"
    sql += "WHERE locations.id = $1\n"
    sql += "ORDER BY "
    sql += (0..Resource::MAX_TREE_LEVELS - 1).map{ |lv| "lv#{lv}_name" }.join(', ')

    values = [[ nil, self.id ]]

    ActiveRecord::Base.connection.exec_query(sql, 'SQL', values)
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
