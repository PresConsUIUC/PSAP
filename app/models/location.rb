##
# A Location exists within a Repository. It can contain zero or more Resources.
#
class Location < ActiveRecord::Base
  has_and_belongs_to_many :events
  belongs_to :repository, inverse_of: :locations
  has_many :resources, inverse_of: :location, dependent: :destroy
  belongs_to :temperature_range, inverse_of: :location, dependent: :destroy

  accepts_nested_attributes_for :temperature_range

  validates :name, presence: true, length: { maximum: 255 }
  validates :repository, presence: true
end
