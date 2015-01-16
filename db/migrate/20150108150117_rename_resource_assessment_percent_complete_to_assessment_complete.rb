class RenameResourceAssessmentPercentCompleteToAssessmentComplete < ActiveRecord::Migration
  def change
    remove_column :resources, :assessment_percent_complete
    add_column :resources, :assessment_complete, :boolean
  end
end
