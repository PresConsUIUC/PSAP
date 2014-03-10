class Role < ActiveRecord::Base
  has_many :permissions, inverse_of: :role
  has_many :users, inverse_of: :role

  def has_permission?(key)
    self.permissions.each do |p|
      return true if p.key == key
    end
    return false;
  end

end
