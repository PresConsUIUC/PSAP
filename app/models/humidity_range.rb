class HumidityRange < ActiveRecord::Base
  belongs_to :format, inverse_of: :humidity_ranges
  has_one :location, inverse_of: :humidity_range

  validates :max_rh, presence: true
  validates :min_rh, presence: true
  validates_numericality_of :score, greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 1, presence: true

  validate :validate_max_greater_than_min

  def validate_max_greater_than_min
    if self.min_rh and self.max_rh and self.min_rh >= self.max_rh
      errors[:base] << ('Maximum relative humidity must be greater than minimum RH.')
    end
  end

end
