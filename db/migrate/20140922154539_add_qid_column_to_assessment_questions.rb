class AddQidColumnToAssessmentQuestions < ActiveRecord::Migration
  def change
    add_column :assessment_questions, :qid, :integer
  end
end
