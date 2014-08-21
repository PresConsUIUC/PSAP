class AddFormatReferenceToAssessmentQuestions < ActiveRecord::Migration
  def change
    add_reference :assessment_questions, :format, index: true
  end
end
