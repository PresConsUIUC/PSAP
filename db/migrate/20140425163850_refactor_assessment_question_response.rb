class RefactorAssessmentQuestionResponse < ActiveRecord::Migration
  def change
    remove_reference :assessment_question_responses, :assessment_question
    add_reference :assessment_question_responses, :assessment_question_option,
                  index: false
    remove_column :assessment_question_responses, :value

    add_index :assessment_question_responses, :assessment_question_option_id,
              name: 'assessment_question_option_id'
  end
end
