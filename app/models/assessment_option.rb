class AssessmentOption < ActiveRecord::Base
  belongs_to :assessment

  validates :name, length: { minimum: 2, maximum: 255 }
end
