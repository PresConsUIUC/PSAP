class Location < ActiveRecord::Base
  belongs_to :repository
  has_many :resources

  attr_accessor :name

  validates :name, length: { maximum: 255 }
end
