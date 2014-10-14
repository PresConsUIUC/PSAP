class FixColumnsForPostgres < ActiveRecord::Migration
  def up
    change_column :assessment_questions, :weight, :decimal, precision: 5, scale: 3
    change_column :resources, :significance, :decimal, precision: 2, scale: 1
  end

  def down
    change_column :assessment_questions, :weight, :decimal, precision: 4, scale: 3
    change_column :resources, :significance, :decimal, precision: 1, scale: 1
  end
end
