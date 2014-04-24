class MovePercentCompleteColumnFromResourcesToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :percent_complete, :float, default: 0.0
    remove_column :resources, :percent_complete
  end
end
