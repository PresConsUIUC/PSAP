class Location < ActiveRecord::Base
  belongs_to :repository
  has_many :resources

  validates :name, length: { maximum: 255 }
end
