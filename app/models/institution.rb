class Institution < ActiveRecord::Base
  has_many :users, inverse_of: :institution, dependent: :restrict
  has_many :repositories, inverse_of: :institution, dependent: :destroy

  has_many :locations, through: :repositories
  has_many :resources, through: :locations

  validates :address1, presence: true, length: { maximum: 255 }
  validates :address2, length: { maximum: 255 }
  validates :city, presence: true, length: { maximum: 255 }
  validates :state, presence: true, length: { maximum: 30 }
  validates :postal_code, presence: true, length: { maximum: 30 }
  validates :country, presence: true, length: { maximum: 255 }

  # Creation will be logged during user creation.
  after_update :log_update
  after_destroy :log_destroy

  validates :name, length: { minimum: 2, maximum: 255 },
            uniqueness: { case_sensitive: false }

  def log_update
    Event.create(description: "Edited institution #{self.name}",
                 user: User.current_user)
  end

  def log_destroy
    Event.create(description: "Deleted institution #{self.name}",
                 user: User.current_user)
  end

end
