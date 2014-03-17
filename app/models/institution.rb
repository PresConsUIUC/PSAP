class Institution < ActiveRecord::Base
  has_many :users, inverse_of: :institution, dependent: :restrict
  has_many :repositories, inverse_of: :institution, dependent: :destroy

  has_many :locations, through: :repositories
  has_many :resources, through: :locations
  has_many :assessments, through: :resources


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
