class DropAssessmentOptionsTable < ActiveRecord::Migration
  def change
    drop_table :assessment_options if table_exists? :assessment_options
  end
end
