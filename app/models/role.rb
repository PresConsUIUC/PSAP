class Role < ActiveRecord::Base
  has_and_belongs_to_many :permissions
  has_many :users, inverse_of: :role

  def has_permission?(key)
    return true if self.is_admin
    self.permissions.each do |p|
      return true if p.key == key
    end
    return false;
  end

end
