class RemoveAssessmentSectionWeights < ActiveRecord::Migration
  def change
    remove_column :assessment_sections, :weight
  end
end
