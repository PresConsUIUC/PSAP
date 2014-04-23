class AddHelpTextColumnToAssessmentQuestions < ActiveRecord::Migration
  def change
    add_column :assessment_questions, :help_text, :string
  end
end
