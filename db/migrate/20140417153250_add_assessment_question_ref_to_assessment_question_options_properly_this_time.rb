class AddAssessmentQuestionRefToAssessmentQuestionOptionsProperlyThisTime < ActiveRecord::Migration
  def change
    add_reference :assessment_question_options, :assessment_question, index: true
    remove_reference :assessment_questions, :assessment_question_option
  end
end
