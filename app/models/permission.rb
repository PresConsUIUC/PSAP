class Permission < ActiveRecord::Base
  belongs_to :role, inverse_of: :permissions

  def name
    # TODO: return localized name based on key
  end

end
