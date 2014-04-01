class Repository < ActiveRecord::Base
  belongs_to :institution, inverse_of: :repositories
  has_many :locations, inverse_of: :repository

  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy

  validates :institution, presence: true
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }

  def log_create
    Event.create(description: "Created repository #{self.name} in institution #{self.institution.name}",
                 user: User.current_user)
  end

  def log_update
    Event.create(description: "Edited repository #{self.name} in institution #{self.institution.name}",
                 user: User.current_user)
  end

  def log_destroy
    Event.create(description: "Deleted repository #{self.name} from institution #{self.institution.name}",
                 user: User.current_user)
  end

end
