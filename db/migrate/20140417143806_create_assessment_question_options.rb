class CreateAssessmentQuestionOptions < ActiveRecord::Migration
  def change
    create_table :assessment_question_options do |t|
      t.integer :index
      t.string :name
      t.string :value

      t.timestamps
    end
    add_reference :assessment_sections, :assessment_question_option, index: true
    add_reference :assessment_questions, :selected_option, index: true
  end
end
