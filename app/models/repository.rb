class Repository < ActiveRecord::Base
  has_and_belongs_to_many :events
  belongs_to :institution, inverse_of: :repositories
  has_many :locations, inverse_of: :repository, dependent: :destroy

  validates :institution, presence: true
  validates :name, presence: true, length: { maximum: 255 }

end
