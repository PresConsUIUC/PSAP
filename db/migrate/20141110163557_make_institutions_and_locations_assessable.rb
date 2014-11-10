class MakeInstitutionsAndLocationsAssessable < ActiveRecord::Migration
  def up
    add_column :assessment_question_responses, :location_id, :integer
    add_column :assessment_question_responses, :institution_id, :integer
    change_column :assessment_question_responses, :resource_id, :integer, null: true
  end

  def down
    remove_column :assessment_question_responses, :location_id, :integer
    remove_column :assessment_question_responses, :institution_id, :integer
    change_column :assessment_question_responses, :resource_id, :integer, null: false
  end
end
