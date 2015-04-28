class AddSomeIndexes < ActiveRecord::Migration
  def change
    add_index :assessment_question_options_questions, :assessment_question_id,
              name: 'index_aqos_questions_on_assessment_question_id'
    add_index :assessment_question_options_questions,
              :assessment_question_option_id,
              name: 'index_aqos_questions_on_assessment_question_option_id'

    add_index :assessment_question_responses, :location_id
    add_index :assessment_question_responses, :institution_id

    add_index :assessment_questions, :qid

    add_index :assessment_questions_formats, :assessment_question_id
    add_index :assessment_questions_formats, :format_id

    add_index :assessment_questions_institutions, :assessment_question_id,
              name: 'index_aqs_institutions_on_assessment_question_id'
    add_index :assessment_questions_institutions, :institution_id,
              name: 'index_aqs_institutions_on_institution_id'

    add_index :assessment_questions_locations, :assessment_question_id,
              name: 'index_aqs_locations_on_assessment_question_id'
    add_index :assessment_questions_locations, :location_id,
              name: 'index_aqs_locations_on_location_id'

    add_index :events, :created_at

    add_index :events_assessment_questions, :assessment_question_id,
              name: 'index_events_aqs_on_assessment_question_id'
    add_index :events_assessment_questions, :event_id,
              name: 'index_events_aqs_on_event_id'

    add_index :events_assessment_sections, :assessment_section_id,
              name: 'index_events_ass_on_ass_id'
    add_index :events_assessment_sections, :event_id,
              name: 'index_events_ass_on_event_id'

    add_index :events_assessments, :assessment_id
    add_index :events_assessments, :event_id

    add_index :events_formats, :format_id
    add_index :events_formats, :event_id

    add_index :events_institutions, :institution_id
    add_index :events_institutions, :event_id

    add_index :events_locations, :location_id
    add_index :events_locations, :event_id

    add_index :events_repositories, :repository_id
    add_index :events_repositories, :event_id

    add_index :events_resources, :resource_id
    add_index :events_resources, :event_id

    add_index :events_users, :user_id
    add_index :events_users, :event_id

    add_index :formats, :fid

    add_index :humidity_ranges, :min_rh
    add_index :humidity_ranges, :max_rh

    add_index :permissions_roles, :permission_id
    add_index :permissions_roles, :role_id

    add_index :resources, :language_id
    add_index :resources, :format_ink_media_type_id
    add_index :resources, :format_support_type_id

    add_index :static_pages, :category
    add_index :static_pages, :name

    add_index :subjects, :name

    add_index :temperature_ranges, :min_temp_f
    add_index :temperature_ranges, :max_temp_f
  end
end
