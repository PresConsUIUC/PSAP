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

  def humidity_range
    response = self.response_to_question(AssessmentQuestion.find_by_qid(1024))
    if response
      values = response.assessment_question_option.name.gsub('–', '-').split('-').
          map{ |v| v.gsub(/\D/, '').to_i }
      if values.length == 2
        return HumidityRange.new(min_rh: values[0], max_rh: values[1])
      end
    end
    nil
  end

  def temperature_range
    response = self.response_to_question(AssessmentQuestion.find_by_qid(1022))
    if response
      values = response.assessment_question_option.name.gsub('–', '-').split('-').
          map{ |v| v.gsub(/\D/, '').to_i }
      if values.length == 2
        return TemperatureRange.new(min_temp_f: values[0], max_temp_f: values[1])
      end
    end
    nil
  end

end
