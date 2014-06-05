class AddResourceRefToAssessment < ActiveRecord::Migration
  def change
    create_table :assessments do |t|
      t.string name
      t.timestamps
    end
    add_reference :assessments, :resource, index: true
  end
end
