class Subject < ActiveRecord::Base
  belongs_to :resource, inverse_of: :subjects

  validates :resource, presence: true
end
