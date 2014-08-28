class RefactorEnablingAssessmentQuestionOptions < ActiveRecord::Migration
  def change
    remove_column :assessment_questions, :enabling_assessment_question_option_id, :integer

    create_table :assessment_question_options_questions do |t|
      t.integer :assessment_question_id
      t.integer :assessment_question_option_id
    end
  end
end
