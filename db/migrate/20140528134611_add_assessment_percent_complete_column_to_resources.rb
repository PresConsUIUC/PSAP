class AddAssessmentPercentCompleteColumnToResources < ActiveRecord::Migration
  def change
    add_column :resources, :assessment_percent_complete, :float, default: 0
  end
end
