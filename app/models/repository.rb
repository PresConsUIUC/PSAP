class Repository < ActiveRecord::Base
  belongs_to :institution
  has_many :locations
end
