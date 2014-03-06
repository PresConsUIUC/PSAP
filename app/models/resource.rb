class Resource < ActiveRecord::Base
  belongs_to :location
  has_one :assessment

  attr_accessor :name

  validates :name, length: { maximum: 255 }
end
