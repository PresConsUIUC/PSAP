class Role < ActiveRecord::Base
  has_and_belongs_to_many :permissions
  has_many :users, inverse_of: :role

  validates :name, presence: true, length: { maximum: 30 },
            uniqueness: { case_sensitive: false }

  def has_permission?(key)
    self.is_admin? || self.permissions.select{ |p| p.key == key }.any?
  end

end
