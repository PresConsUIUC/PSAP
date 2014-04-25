class ChangeTypeOfAssessmentQuestionOptionValue < ActiveRecord::Migration
  def change
    change_column :assessment_question_options, :value, :float
  end
end
