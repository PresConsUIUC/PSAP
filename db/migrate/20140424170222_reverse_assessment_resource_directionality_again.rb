class ReverseAssessmentResourceDirectionalityAgain < ActiveRecord::Migration
  def change
    remove_reference :assessments, :resource
    add_reference :resources, :assessment, index: true
  end
end
