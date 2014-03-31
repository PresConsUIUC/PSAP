class DropAssessmentOptionsTable < ActiveRecord::Migration
  def change
    drop_table :assessment_options
  end
end
