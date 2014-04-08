class Extent < ActiveRecord::Base
  belongs_to :resource, inverse_of: :extents

  validates :name, presence: true
  validates :resource, presence: true
end
