class Extent < ActiveRecord::Base
  belongs_to :resource, inverse_of: :extents

  validates :resource, presence: true
end
