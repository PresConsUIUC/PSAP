class Location < ActiveRecord::Base
  belongs_to :repository, inverse_of: :locations
  has_many :resources, inverse_of: :location, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
end
