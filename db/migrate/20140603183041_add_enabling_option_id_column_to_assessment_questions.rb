class AddEnablingOptionIdColumnToAssessmentQuestions < ActiveRecord::Migration
  def change
    add_column :assessment_questions, :enabling_assessment_question_option_id, :integer
  end
end
