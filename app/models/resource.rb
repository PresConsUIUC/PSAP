class Resource < ActiveRecord::Base
  belongs_to :location, inverse_of: :resources
  has_one :assessment
  has_many :children, class_name: 'Resource', foreign_key: 'parent_id',
           inverse_of: :parent
  belongs_to :parent, class_name: 'Resource', inverse_of: :children

  validates :location, presence: true
  validates :name, length: { maximum: 255 }
  validates :resource_type, presence: true

  def readable_resource_type
    case resource_type
      when 0
        'Collection'
      when 1
        'Item'
    end
  end

end
