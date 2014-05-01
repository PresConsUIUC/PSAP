class Assessment < ActiveRecord::Base
  has_many :assessment_sections, inverse_of: :assessment, dependent: :destroy

  validates :key, presence: true, length: { maximum: 30 }
  validates :name, presence: true, length: { maximum: 255 }

  def to_param
    key
  end

  def readonly?
    !new_record?
  end

end
