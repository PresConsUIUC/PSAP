class Creator < ActiveRecord::Base

  class Type
    PERSON = 0
    COMPANY = 1

    def self.all
      return (0..1)
    end
  end

  belongs_to :resource, inverse_of: :creators

  validates :creator_type, presence: true,
            inclusion: { in: Creator::Type.all,
                         message: 'Must be a valid creator type.' }
  validates :name, presence: true, length: { maximum: 255 }
  validates :resource, presence: true

  def readable_creator_type
    case creator_type
      when Creator::Type::PERSON
        'Person'
      when Creator::Type::COMPANY
        'Company'
    end
  end

end
