class CreateAssessmentOptions < ActiveRecord::Migration
  def change
    create_table :assessment_options do |t|
      t.string :name

      t.timestamps
    end
  end
end
