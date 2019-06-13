class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :assessment_question_options, :assessment_questions
    add_foreign_key :assessment_question_options_questions, :assessment_questions
    add_foreign_key :assessment_question_options_questions, :assessment_question_options
    add_foreign_key :assessment_question_responses, :assessment_questions
    add_foreign_key :assessment_question_responses, :assessment_question_options
    add_foreign_key :assessment_question_responses, :institutions
    add_foreign_key :assessment_question_responses, :locations
    add_foreign_key :assessment_question_responses, :resources
    add_foreign_key :assessment_questions, :assessment_question_options, column: :selected_option_id
    add_foreign_key :assessment_questions, :assessment_questions, column: :parent_id
    add_foreign_key :assessment_questions, :assessment_sections
    add_foreign_key :assessment_questions_formats, :assessment_questions
    add_foreign_key :assessment_questions_formats, :formats
    add_foreign_key :assessment_questions_institutions, :assessment_questions
    add_foreign_key :assessment_questions_institutions, :institutions
    add_foreign_key :assessment_questions_locations, :assessment_questions
    add_foreign_key :assessment_questions_locations, :locations
    add_foreign_key :assessment_sections, :assessments
    add_foreign_key :creators, :resources,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :extents, :resources,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :formats, :formats, column: :parent_id,
                    on_delete: :nullify, on_update: :cascade
    add_foreign_key :humidity_ranges, :formats,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :institutions, :languages,
                    on_delete: :restrict, on_update: :cascade
    add_foreign_key :locations, :repositories,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :locations, :humidity_ranges,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :locations, :temperature_ranges,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :permissions_roles, :permissions,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :permissions_roles, :roles,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :repositories, :institutions,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :resource_dates, :resources,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :resource_notes, :resources,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :resources, :locations,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :resources, :resources, column: :parent_id,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :resources, :formats,
                    on_delete: :restrict, on_update: :cascade
    add_foreign_key :resources, :users,
                    on_delete: :nullify, on_update: :cascade
    add_foreign_key :resources, :assessments,
                    on_delete: :nullify, on_update: :cascade
    add_foreign_key :resources, :languages,
                    on_delete: :restrict, on_update: :cascade
    add_foreign_key :resources, :format_ink_media_types,
                    on_delete: :restrict, on_update: :cascade
    add_foreign_key :resources, :format_support_types,
                    on_delete: :restrict, on_update: :cascade
    add_foreign_key :subjects, :resources,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :temperature_ranges, :formats,
                    on_delete: :cascade, on_update: :cascade
    add_foreign_key :users, :institutions,
                    on_delete: :restrict, on_update: :cascade
    add_foreign_key :users, :institutions, column: :desired_institution_id,
                    on_delete: :nullify, on_update: :cascade

    change_column_null :resources, :user_id, true
  end
end
