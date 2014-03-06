class Institution < ActiveRecord::Base
  has_many :users

  attr_accessor :name

  validates :name, length: { minimum: 2, maximum: 255 }
end
