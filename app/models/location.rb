class Location < ActiveRecord::Base
  has_and_belongs_to_many :locations
  belongs_to :repository, inverse_of: :locations
  has_many :resources, inverse_of: :location, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :repository, presence: true
end
