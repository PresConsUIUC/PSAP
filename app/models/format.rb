class Format < ActiveRecord::Base
  has_many :resources, inverse_of: :format
  has_many :temperature_ranges, inverse_of: :format, dependent: :destroy

  accepts_nested_attributes_for :temperature_ranges

  validates :name, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }
  validates :score, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  validate :validates_ranges_are_sequential

  after_initialize :after_initialize

  def after_initialize
    if self.new_record?
      self.temperature_ranges << TemperatureRange.create(min_temp_f: 0,
                                                         max_temp_f: 100,
                                                         score: 1)
    end
  end

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
