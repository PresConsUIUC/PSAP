class CreateAssessmentQuestions < ActiveRecord::Migration
  def change
    create_table :assessment_questions do |t|
      t.integer :index
      t.string :name
      t.integer :question_type
      t.float :weight

      t.timestamps
    end
    add_reference :assessment_questions, :assessment_section, index: true
    add_reference :assessment_questions, :assessment_question, index: true
  end
end
