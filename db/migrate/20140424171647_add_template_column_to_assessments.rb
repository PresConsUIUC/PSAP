class AddTemplateColumnToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :is_template, :boolean, default: false
  end
end
