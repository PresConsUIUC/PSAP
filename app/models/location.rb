class Location < ActiveRecord::Base
  belongs_to :repository, inverse_of: :locations
  has_many :resources, inverse_of: :location

  validates :name, length: { maximum: 255 }
end
