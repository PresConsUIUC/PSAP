class Language < ActiveRecord::Base
  has_many :institutions, inverse_of: :language
  has_many :resources, inverse_of: :language

  validates :english_name, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }
  validates :iso639_2_code, presence: true, length: { minimum: 3, maximum: 3 },
            uniqueness: { case_sensitive: false }
  validates :native_name, presence: true, length: { maximum: 255 }
end
