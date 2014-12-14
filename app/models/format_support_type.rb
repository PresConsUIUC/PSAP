##
# One of the "vectors" of a Bound or Unbound Paper format, alongside
# FormatInkMediaType.
#
class FormatSupportType < ActiveRecord::Base
  has_many :resources, inverse_of: :format_ink_media_type,
           dependent: :restrict_with_exception

  validates :name, presence: true, length: { maximum: 255 }
  validates :score, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
