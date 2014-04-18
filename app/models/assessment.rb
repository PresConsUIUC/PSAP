class Assessment < ActiveRecord::Base
  has_many :assessment_sections, inverse_of: :assessment, dependent: :destroy
end
