class Format < ActiveRecord::Base
  has_many :resources, inverse_of: :format

  validates :name, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }
  validates :score, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
