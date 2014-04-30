class AddWeightColumnToAssessmentSections < ActiveRecord::Migration
  def change
    add_column :assessment_sections, :weight, :decimal, precision: 4, scale: 3
    change_column_null :assessment_sections, :weight, false
  end
end
