class AddAssessmentScoreColumnToResources < ActiveRecord::Migration
  def change
    add_column :resources, :assessment_score, :float, default: 0
  end
end
