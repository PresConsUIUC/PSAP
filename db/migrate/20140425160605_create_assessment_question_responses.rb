class CreateAssessmentQuestionResponses < ActiveRecord::Migration
  def change
    create_table :assessment_question_responses do |t|
      t.float :value
      t.timestamps
    end
    add_reference :assessment_question_responses, :resource, index: true
    add_reference :assessment_question_responses, :assessment_question, index: true
  end
end
