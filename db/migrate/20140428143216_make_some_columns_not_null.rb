class MakeSomeColumnsNotNull < ActiveRecord::Migration
  def change
    change_column_null :assessment_question_options, :assessment_question_id, false
    change_column_null :assessment_question_options, :index, false
    change_column_null :assessment_question_options, :name, false
    change_column_null :assessment_question_options, :value, false

    change_column_null :assessment_question_responses, :assessment_question_option_id, false
    change_column_null :assessment_question_responses, :resource_id, false

    change_column_null :assessment_questions, :assessment_section_id, false
    change_column_null :assessment_questions, :index, false
    change_column_null :assessment_questions, :name, false
    change_column_null :assessment_questions, :question_type, false
    change_column_null :assessment_questions, :weight, false

    change_column_null :assessment_sections, :assessment_id, false
    change_column_null :assessment_sections, :index, false
    change_column_null :assessment_sections, :name, false

    change_column_null :assessments, :key, false
    change_column_null :assessments, :name, false
    change_column_null :assessments, :percent_complete, false

    change_column_null :creators, :creator_type, false
    change_column_null :creators, :name, false
    change_column_null :creators, :resource_id, false

    change_column_null :events, :description, false

    change_column_null :extents, :name, false
    change_column_null :extents, :resource_id, false

    change_column_null :formats, :name, false
    change_column_null :formats, :score, false

    change_column_null :institutions, :address1, false
    change_column_null :institutions, :city, false
    change_column_null :institutions, :name, false
    change_column_null :institutions, :state, false
    change_column_null :institutions, :postal_code, false
    change_column_null :institutions, :country, false

    change_column_null :languages, :english_name, false
    change_column_null :languages, :iso639_2_code, false
    change_column_null :languages, :native_name, false

    change_column_null :locations, :name, false
    change_column_null :locations, :repository_id, false

    change_column_null :repositories, :institution_id, false
    change_column_null :repositories, :name, false

    change_column_null :resource_dates, :date_type, false
    change_column_null :resource_dates, :resource_id, false

    change_column_null :resources, :location_id, false
    change_column_null :resources, :name, false
    change_column_null :resources, :resource_type, false
    change_column_null :resources, :user_id, false

    change_column_null :subjects, :name, false
    change_column_null :subjects, :resource_id, false

    change_column_null :temperature_ranges, :format_id, false
  end
end
