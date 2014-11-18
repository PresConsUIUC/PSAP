class AddAssessmentScoreColumnToLocationsAndInstitutions < ActiveRecord::Migration
  def change
    add_column :locations, :assessment_score, :float, default: 0
    add_column :institutions, :assessment_score, :float, default: 0
  end
end
