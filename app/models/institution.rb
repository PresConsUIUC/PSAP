class Institution < ActiveRecord::Base
  has_many :users, inverse_of: :institution, dependent: :restrict_with_exception
  has_many :repositories, inverse_of: :institution, dependent: :destroy
  has_and_belongs_to_many :events
  belongs_to :language, inverse_of: :institutions
  has_many :locations, through: :repositories
  has_many :resources, through: :locations

  validates :address1, presence: true, length: { maximum: 255 }
  validates :address2, length: { maximum: 255 }
  validates :city, presence: true, length: { maximum: 255 }
  validates :name, presence: true, length: { minimum: 4, maximum: 255 },
            uniqueness: { case_sensitive: false }
  validates :state, presence: true, length: { maximum: 30 }
  validates :postal_code, presence: true, length: { maximum: 30 }
  validates :country, presence: true, length: { maximum: 255 }
  validates :url, allow_blank: true, format: URI::regexp(%w(http https))

end
