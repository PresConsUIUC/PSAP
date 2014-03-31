class DropAssessmentsTable < ActiveRecord::Migration
  def change
    drop_table :assessments
  end
end
