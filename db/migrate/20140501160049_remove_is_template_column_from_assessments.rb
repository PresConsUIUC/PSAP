class RemoveIsTemplateColumnFromAssessments < ActiveRecord::Migration
  def change
    remove_column :assessments, :is_template, :boolean
  end
end
