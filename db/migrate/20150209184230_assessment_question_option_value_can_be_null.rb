class AssessmentQuestionOptionValueCanBeNull < ActiveRecord::Migration
  def change
    change_column :assessment_question_options, :value, :decimal,
                  precision: 4, scale: 3, null: true
  end
end
