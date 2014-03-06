class Institution < ActiveRecord::Base
  has_many :users

  validates :name, length: { minimum: 2, maximum: 255 }
end
