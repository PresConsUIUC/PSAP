class ResourceNote < ApplicationRecord
  belongs_to :resource, inverse_of: :resource_notes

  validates :resource, presence: true
  validates :value, presence: true
end
