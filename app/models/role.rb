class Role < ActiveRecord::Base
  has_and_belongs_to_many :permissions
  has_many :users, inverse_of: :role

  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy

  def has_permission?(key)
    return true if self.is_admin
    self.permissions.each do |p|
      return true if p.key == key
    end
    return false;
  end

  def log_create
    Event.create(description: "Created role #{self.name}",
                 user: User.current_user)
  end

  def log_update
    Event.create(description: "Edited role #{self.name}",
                 user: User.current_user)
  end

  def log_destroy
    Event.create(description: "Deleted role #{self.name}",
                 user: User.current_user)
  end

end
