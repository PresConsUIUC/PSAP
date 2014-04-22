class RenameParentFkOnAssessmentQuestions < ActiveRecord::Migration
  def change
    rename_column :assessment_questions, :assessment_question_id, :parent_id
  end
end
