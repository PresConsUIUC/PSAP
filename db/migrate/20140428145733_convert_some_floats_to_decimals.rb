class ConvertSomeFloatsToDecimals < ActiveRecord::Migration
  def change
    change_column :assessment_question_options, :value, :decimal, precision: 4, scale: 3
    change_column :assessment_questions, :weight, :decimal, precision: 4, scale: 3
    change_column :formats, :score, :decimal, precision: 4, scale: 3
    change_column :temperature_ranges, :score, :decimal, precision: 4, scale: 3
  end
end
