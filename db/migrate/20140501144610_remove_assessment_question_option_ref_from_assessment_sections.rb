class RemoveAssessmentQuestionOptionRefFromAssessmentSections < ActiveRecord::Migration
  def change
    remove_column :assessment_sections, :assessment_question_option_id
  end
end
