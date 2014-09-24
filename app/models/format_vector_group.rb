##
# A format vector group is a group in which zero or more FormatInkMediaTypes or
# FormatSupportTypes reside.
#
class FormatVectorGroup < ActiveRecord::Base
  has_many :format_ink_media_types, inverse_of: :format
  has_many :format_support_types, inverse_of: :format

  validates :name, presence: true, length: { maximum: 255 }
end
