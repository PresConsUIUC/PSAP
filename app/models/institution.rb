class Institution < ActiveRecord::Base
  has_many :users, inverse_of: :institution
  has_many :repositories, inverse_of: :institution

  validates :name, length: { minimum: 2, maximum: 255 }
end
