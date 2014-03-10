class Assessment < ActiveRecord::Base
  belongs_to :resource, dependent: :delete
  has_many :assessment_options

  validates :name, length: { minimum: 2, maximum: 255 }
end
