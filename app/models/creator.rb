class Creator < ActiveRecord::Base
  belongs_to :resource, inverse_of: :creators

  validates :creator_type, presence: true
  validates :resource, presence: true

  def readable_creator_type
    case creator_type
      when CreatorType::PERSON
        'Person'
      when CreatorType::COMPANY
        'Company'
    end
  end

end
