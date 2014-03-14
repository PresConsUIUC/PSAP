class Location < ActiveRecord::Base
  belongs_to :repository, inverse_of: :locations
  has_many :resources, inverse_of: :location

  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy

  validates :name, length: { maximum: 255 }

  def log_create
    Event.create(description: "Created location #{self.name} in repository #{self.repository.name}",
                 user: User.current_user)
  end

  def log_update
    Event.create(description: "Edited location #{self.name} in repository #{self.repository.name}",
                 user: User.current_user)
  end

  def log_destroy
    Event.create(description: "Deleted location #{self.name} from repository #{self.repository.name}",
                 user: User.current_user)
  end

end
