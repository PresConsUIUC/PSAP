class Institution < ActiveRecord::Base
  has_many :users, inverse_of: :institution, dependent: :restrict
  has_many :repositories, inverse_of: :institution, dependent: :destroy

  validates :name, length: { minimum: 2, maximum: 255 }
end
