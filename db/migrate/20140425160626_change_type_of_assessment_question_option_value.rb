class ChangeTypeOfAssessmentQuestionOptionValue < ActiveRecord::Migration
  def change
    if AssessmentQuestionOption.columns_hash['value'].type == :string
      change_column :assessment_question_options, :value,
                    'float USING CAST(value AS float)'
    else
      change_column :assessment_question_options, :value, :float
    end
  end
end
