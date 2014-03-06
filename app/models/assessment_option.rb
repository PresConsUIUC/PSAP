class AssessmentOption < ActiveRecord::Base
  belongs_to :assessment

  attr_accessor :name

  validates :name, length: { minimum: 2, maximum: 255 }
end
