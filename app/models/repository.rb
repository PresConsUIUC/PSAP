class Repository < ActiveRecord::Base
  belongs_to :institution, inverse_of: :repositories
  has_many :locations, inverse_of: :repository, dependent: :destroy

  validates :institution, presence: true
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }

end
