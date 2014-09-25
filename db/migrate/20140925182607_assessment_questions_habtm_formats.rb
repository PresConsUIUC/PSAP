class AssessmentQuestionsHabtmFormats < ActiveRecord::Migration
  def change
    remove_column :assessment_questions, :format_id
    create_join_table :assessment_questions, :formats
  end
end
