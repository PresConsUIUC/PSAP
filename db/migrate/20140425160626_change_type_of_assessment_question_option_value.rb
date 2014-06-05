class ChangeTypeOfAssessmentQuestionOptionValue < ActiveRecord::Migration
  def change
    if column_exists? :assessment_question_options, :value
      change_column :assessment_question_options, :value,
                    'float USING CAST(value AS float)'
    end
  end
end
