class Event < ActiveRecord::Base
  belongs_to :user

  validates :description, presence: true
  validates :event_status, allow_blank: true,
            inclusion: { in: EventStatus.all,
                         message: 'Must be a valid event type.' }

  def readonly?
    !new_record?
  end

end
