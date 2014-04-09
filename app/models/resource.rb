class Resource < ActiveRecord::Base
  has_many :children, class_name: 'Resource', foreign_key: 'parent_id',
           inverse_of: :parent, dependent: :destroy
  has_many :creators, inverse_of: :resource, dependent: :destroy
  has_many :resource_dates, inverse_of: :resource, dependent: :destroy
  has_many :extents, inverse_of: :resource, dependent: :destroy
  has_many :subjects, inverse_of: :resource, dependent: :destroy
  belongs_to :format, inverse_of: :resources
  belongs_to :location, inverse_of: :resources
  belongs_to :parent, class_name: 'Resource', inverse_of: :children
  belongs_to :user, inverse_of: :resources

  accepts_nested_attributes_for :creators
  accepts_nested_attributes_for :extents
  accepts_nested_attributes_for :resource_dates
  accepts_nested_attributes_for :subjects

  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy

  validates :date_type, allow_blank: true, inclusion: { in: DateType.all,
                                     message: 'Must be a valid date type.' }
  validates :location, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :resource_type, presence: true
  validates :user, presence: true

  def readable_resource_type
    case resource_type
      when ResourceType::COLLECTION
        'Collection'
      when ResourceType::ITEM
        'Item'
    end
  end

  def log_create
    Event.create(description: "Created resource #{self.name} in location #{self.location.name}",
                 user: User.current_user)
  end

  def log_update
    Event.create(description: "Edited resource #{self.name} in location #{self.location.name}",
                 user: User.current_user)
  end

  def log_destroy
    Event.create(description: "Deleted resource #{self.name} from location #{self.location.name}",
                 user: User.current_user)
  end

end
