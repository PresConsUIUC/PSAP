class AddResourceRefToAssessment < ActiveRecord::Migration
  def change
    add_reference :assessments, :resource, index: true
  end
end
