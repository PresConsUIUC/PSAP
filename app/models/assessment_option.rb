class AssessmentOption < ActiveRecord::Base
  belongs_to :assessment, autosave, dependent: :delete

  validates :name, length: { minimum: 2, maximum: 255 }
end
