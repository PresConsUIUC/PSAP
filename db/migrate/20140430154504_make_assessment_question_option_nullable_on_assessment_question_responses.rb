class MakeAssessmentQuestionOptionNullableOnAssessmentQuestionResponses < ActiveRecord::Migration
  def change
    change_column_null :assessment_question_responses,
                       :assessment_question_option_id, true
  end
end
