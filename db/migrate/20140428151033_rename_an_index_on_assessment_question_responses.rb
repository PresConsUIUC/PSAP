class RenameAnIndexOnAssessmentQuestionResponses < ActiveRecord::Migration
  def change
    rename_index :assessment_question_responses, :assessment_question_option_id,
                 :index_assessment_question_options
  end
end
