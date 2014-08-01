class TemperatureRange < ActiveRecord::Base
  belongs_to :format, inverse_of: :temperature_ranges
  has_one :location, inverse_of: :temperature_range

  validates_numericality_of :score, greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 1, presence: true
  validate :validate_min_or_max_range_required
  validate :validate_max_greater_than_min

  def validate_max_greater_than_min
    if self.min_temp_f && self.max_temp_f && self.min_temp_f >= self.max_temp_f
      errors[:base] << ('Maximum temperature must be greater than minimum temperature.')
    end
  end

  def validate_min_or_max_range_required
    if [self.min_temp_f, self.max_temp_f].reject(&:blank?).size == 0
      errors[:base] << ('Either a minimum or maximum temperature is required.')
    end
  end

end
