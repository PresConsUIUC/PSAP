class LinkAssessmentQuestionsToAdvancedHelp < ActiveRecord::Migration
  def change
    add_column :assessment_questions, :advanced_help_page, :string
    add_column :assessment_questions, :advanced_help_anchor, :string
  end
end
