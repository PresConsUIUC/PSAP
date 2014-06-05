class RemoveAssessmentQuestionOptionRefFromAssessmentSectionsAgain < ActiveRecord::Migration
  def change
    remove_column :assessment_sections, :assessment_question_option_id, :integer if
        column_exists? :assessment_sections, :assessment_question_option_id
    remove_column :assessment_sections, :assessment_question_options_id, :integer if
        column_exists? :assessment_sections, :assessment_question_options_id
  end
end
