class Assessment < ActiveRecord::Base
  has_one :resource
  has_many :assessment_options

  attr_accessor :name

  validates :name, length: { minimum: 2, maximum: 255 }
end
