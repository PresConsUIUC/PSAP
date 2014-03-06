class Resource < ActiveRecord::Base
  belongs_to :location
  has_one :assessment

  validates :name, length: { maximum: 255 }
end
