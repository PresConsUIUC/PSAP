class AddAssessmentQuestionRefToAssessmentQuestionResponses < ActiveRecord::Migration
  def change
    add_reference :assessment_question_responses, :assessment_question,
                  index: true
  end
end
