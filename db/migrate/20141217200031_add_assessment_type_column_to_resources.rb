class AddAssessmentTypeColumnToResources < ActiveRecord::Migration
  def change
    add_column :resources, :assessment_type, :integer
  end
end
