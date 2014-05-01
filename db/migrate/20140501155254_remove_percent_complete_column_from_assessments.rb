class RemovePercentCompleteColumnFromAssessments < ActiveRecord::Migration
  def change
    remove_column :assessments, :percent_complete
  end
end
