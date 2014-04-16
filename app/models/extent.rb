class Extent < ActiveRecord::Base
  belongs_to :resource, inverse_of: :extents

  validates :name, presence: true, length: { maximum: 255 }
  validates :resource, presence: true
end
