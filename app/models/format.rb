class Format < ActiveRecord::Base
  has_many :children, class_name: 'Format', foreign_key: 'parent_id',
           inverse_of: :parent, dependent: :destroy
  has_many :resources, inverse_of: :format, dependent: :restrict_with_exception
  has_many :temperature_ranges, inverse_of: :format, dependent: :destroy
  has_and_belongs_to_many :events
  belongs_to :parent, class_name: 'Format', inverse_of: :children

  accepts_nested_attributes_for :temperature_ranges, allow_destroy: true

  validates :format_type, presence: true,
            inclusion: { in: FormatType.all,
                         message: 'Must be a valid format type.' }
  validates :name, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }
  validates :score, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  validate :validates_ranges_are_sequential

  def validates_ranges_are_sequential
    ranges = self.temperature_ranges.sort_by { |obj| obj.min_temp_f or 0 }
    prev_range = nil
    ranges.each do |range|
      if prev_range && range.min_temp_f && range.min_temp_f - prev_range.max_temp_f != 1
        errors[:base] << ('The minimum temperature must be one '\
        'degree greater than the maximum temperature of the next lower range.')
      end
      prev_range = range
    end
  end

end
