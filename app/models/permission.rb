class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles

  def name
    # TODO: return localized name based on key
  end

end
