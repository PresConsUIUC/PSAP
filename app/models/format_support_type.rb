##
# One of the "vectors" of a Bound or Unbound Paper format, alongside
# FormatInkMediaType. Resides in a FormatVectorGroup.
#
class FormatSupportType < ActiveRecord::Base
  belongs_to :format, inverse_of: :format_support_types
  belongs_to :format_vector_group, inverse_of: :format_ink_media_types

  validates :name, presence: true, length: { maximum: 255 }
  validates :score, presence: true, numericality: {
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
