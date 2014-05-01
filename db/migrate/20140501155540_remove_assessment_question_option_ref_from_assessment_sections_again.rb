class RemoveAssessmentQuestionOptionRefFromAssessmentSectionsAgain < ActiveRecord::Migration
  def change
    remove_column :assessment_sections, :assessment_question_option_id, :integer
    remove_column :assessment_sections, :assessment_question_options_id, :integer
  end
end
