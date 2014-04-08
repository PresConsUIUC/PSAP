class Subject < ActiveRecord::Base
  belongs_to :resource, inverse_of: :subjects

  validates :name, presence: true
  validates :resource, presence: true
end
