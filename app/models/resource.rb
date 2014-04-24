class Resource < ActiveRecord::Base
  has_many :children, class_name: 'Resource', foreign_key: 'parent_id',
           inverse_of: :parent, dependent: :destroy
  has_many :creators, inverse_of: :resource, dependent: :destroy
  has_many :resource_dates, inverse_of: :resource, dependent: :destroy
  has_many :extents, inverse_of: :resource, dependent: :destroy
  has_many :subjects, inverse_of: :resource, dependent: :destroy
  belongs_to :assessment, inverse_of: :resource
  belongs_to :format, inverse_of: :resources
  belongs_to :location, inverse_of: :resources
  belongs_to :parent, class_name: 'Resource', inverse_of: :children
  belongs_to :user, inverse_of: :resources

  accepts_nested_attributes_for :creators
  accepts_nested_attributes_for :extents
  accepts_nested_attributes_for :resource_dates
  accepts_nested_attributes_for :subjects

  validates :location, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :resource_type, presence: true
  validates :user, presence: true

  after_initialize :setup, if: :new_record?

  def setup
    # TODO: clone the resource assessment template instead
    self.assessment = Assessment.new(key: 'resource',
                                     name: 'Resource Assessment')
  end

  def readable_resource_type
    case resource_type
      when ResourceType::COLLECTION
        'Collection'
      when ResourceType::ITEM
        'Item'
    end
  end

end
