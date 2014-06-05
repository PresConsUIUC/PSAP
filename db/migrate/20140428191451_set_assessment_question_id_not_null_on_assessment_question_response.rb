class SetAssessmentQuestionIdNotNullOnAssessmentQuestionResponse < ActiveRecord::Migration
  def change
    change_column_null :assessment_question_responses, :assessment_question_id,
                       false
  end
end
