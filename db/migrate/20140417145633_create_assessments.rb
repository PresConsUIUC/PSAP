class CreateAssessments < ActiveRecord::Migration
  def change
    create_table :assessments do |t|

      t.timestamps
    end
  end
end
