class Repository < ActiveRecord::Base

  has_and_belongs_to_many :events
  belongs_to :institution, inverse_of: :repositories
  has_many :locations, -> { order(:name) }, inverse_of: :repository,
           dependent: :destroy
  has_many :resources, -> { order(:name) }, through: :locations

  validates :institution, presence: true
  validates :name, presence: true, length: { maximum: 255 }

  validates_uniqueness_of :name, scope: :institution_id

end
