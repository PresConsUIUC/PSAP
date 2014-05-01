class Event < ActiveRecord::Base
  belongs_to :user

  validates :description, presence: true

  def readonly?
    !new_record?
  end

end
