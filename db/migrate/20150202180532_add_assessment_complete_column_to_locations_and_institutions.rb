class AddAssessmentCompleteColumnToLocationsAndInstitutions < ActiveRecord::Migration
  def change
    add_column :locations, :assessment_complete, :boolean
    add_column :institutions, :assessment_complete, :boolean
  end
end
