class AddNameColumnToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :name, :string
  end
end
