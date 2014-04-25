class AddDescriptionColumnToAssessmentSections < ActiveRecord::Migration
  def change
    add_column :assessment_sections, :description, :string
  end
end
