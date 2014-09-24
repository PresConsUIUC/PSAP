##
# One of the "vectors" of a Bound or Unbound Paper format, alongside
# FormatSupportType. Resides in a FormatVectorGroup.
#
class FormatInkMediaType < ActiveRecord::Base
  belongs_to :format, inverse_of: :format_ink_media_types
  belongs_to :format_vector_group, inverse_of: :format_ink_media_types

  validates :name, presence: true, length: { maximum: 255 }
  validates :score, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
