class RemoveAssessmentResourceRelationship < ActiveRecord::Migration
  def change
    remove_column :assessments, :resource_id if
        column_exists? :assessments, :resource_id
    remove_column :resources, :assessment_id if
        column_exists? :resources, :resource_id
  end
end
