class Assessment < ActiveRecord::Base
  has_one :resource
  has_many :assessment_options

  validates :name, length: { minimum: 2, maximum: 255 }
end
