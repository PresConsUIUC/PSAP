class ReverseAssessmentResourceDirectionality < ActiveRecord::Migration
  def change
    remove_reference :resources, :assessment
    add_reference :assessments, :resource, index: true
  end
end
