class CreateAssessmentQuestionJoinTables < ActiveRecord::Migration
  def change
    create_table :assessment_questions_institutions do |t|
      t.integer :assessment_question_id
      t.integer :institution_id
    end
    create_table :assessment_questions_locations do |t|
      t.integer :assessment_question_id
      t.integer :location_id
    end
  end
end
