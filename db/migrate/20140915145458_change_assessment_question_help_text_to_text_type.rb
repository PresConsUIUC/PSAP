class ChangeAssessmentQuestionHelpTextToTextType < ActiveRecord::Migration
  def change
    change_column :assessment_questions, :help_text, :text, limit: nil
  end
end
