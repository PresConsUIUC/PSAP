class SetAssessmentQuestionIdNotNullOnAssessmentQuestionResponse < ActiveRecord::Migration
  def change
    change_column_null :assessment_question_responses, :assessment_question,
                       false
  end
end
