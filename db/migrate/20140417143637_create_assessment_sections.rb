class CreateAssessmentSections < ActiveRecord::Migration
  def change
    create_table :assessment_sections do |t|
      t.integer :index
      t.string :name

      t.timestamps
    end
    add_reference :assessment_sections, :assessment, index: true
  end
end
