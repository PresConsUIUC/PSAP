class Format < ActiveRecord::Base

  validates :name, presence: true
  validates :obsolete, presence: true
  validates :score, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
