class Subject < ApplicationRecord
  belongs_to :resource, inverse_of: :subjects

  validates :name, presence: true, length: { maximum: 255 }
  validates :resource, presence: true
end
