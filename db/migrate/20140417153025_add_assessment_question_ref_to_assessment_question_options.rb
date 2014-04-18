class AddAssessmentQuestionRefToAssessmentQuestionOptions < ActiveRecord::Migration
  def change
    add_reference :assessment_questions, :assessment_question_option, index: true
  end
end
