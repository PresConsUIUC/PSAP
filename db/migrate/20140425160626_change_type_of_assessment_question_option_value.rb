class ChangeTypeOfAssessmentQuestionOptionValue < ActiveRecord::Migration
  def change
    remove_column :assessment_question_options, :value
    add_column :assessment_question_options, :value, :float
  end
end
