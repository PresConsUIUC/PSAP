class AddKeyColumnToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :key, :string
  end
end
