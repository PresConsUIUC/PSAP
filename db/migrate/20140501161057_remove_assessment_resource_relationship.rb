class RemoveAssessmentResourceRelationship < ActiveRecord::Migration
  def change
    remove_reference :resources, :assessment
    remove_reference :assessments, :resource
    remove_column :assessments, :resource_id if
        column_exists? :assessments, :resource_id
    remove_column :resources, :assessment_id if
        column_exists? :resources, :resource_id
  end
end
