class AddResourceRefToAssessments < ActiveRecord::Migration
  def change
    add_reference :resources, :assessment, index: true
  end
end
