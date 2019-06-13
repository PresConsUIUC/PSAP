# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_13_183949) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assessment_question_options", id: :serial, force: :cascade do |t|
    t.integer "index", null: false
    t.string "name", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "assessment_question_id", null: false
    t.decimal "value", precision: 4, scale: 3
    t.index ["assessment_question_id"], name: "index_assessment_question_options_on_assessment_question_id"
    t.index ["index"], name: "index_assessment_question_options_on_index"
  end

  create_table "assessment_question_options_questions", id: :serial, force: :cascade do |t|
    t.integer "assessment_question_id"
    t.integer "assessment_question_option_id"
    t.index ["assessment_question_id"], name: "index_aqos_questions_on_assessment_question_id"
    t.index ["assessment_question_option_id"], name: "index_aqos_questions_on_assessment_question_option_id"
  end

  create_table "assessment_question_responses", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "resource_id"
    t.integer "assessment_question_option_id"
    t.integer "assessment_question_id", null: false
    t.integer "location_id"
    t.integer "institution_id"
    t.index ["assessment_question_id"], name: "index_assessment_question_responses_on_assessment_question_id"
    t.index ["assessment_question_option_id"], name: "index_assessment_question_options"
    t.index ["institution_id"], name: "index_assessment_question_responses_on_institution_id"
    t.index ["location_id"], name: "index_assessment_question_responses_on_location_id"
    t.index ["resource_id"], name: "index_assessment_question_responses_on_resource_id"
  end

  create_table "assessment_questions", id: :serial, force: :cascade do |t|
    t.integer "index", null: false
    t.string "name", limit: 255, null: false
    t.integer "question_type", null: false
    t.decimal "weight", precision: 5, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "assessment_section_id", null: false
    t.integer "parent_id"
    t.integer "selected_option_id"
    t.text "help_text"
    t.integer "qid"
    t.string "advanced_help_page", limit: 255
    t.string "advanced_help_anchor", limit: 255
    t.index ["assessment_section_id"], name: "index_assessment_questions_on_assessment_section_id"
    t.index ["index"], name: "index_assessment_questions_on_index"
    t.index ["parent_id"], name: "index_assessment_questions_on_parent_id"
    t.index ["qid"], name: "index_assessment_questions_on_qid"
    t.index ["selected_option_id"], name: "index_assessment_questions_on_selected_option_id"
  end

  create_table "assessment_questions_formats", id: false, force: :cascade do |t|
    t.integer "assessment_question_id", null: false
    t.integer "format_id", null: false
    t.index ["assessment_question_id"], name: "index_assessment_questions_formats_on_assessment_question_id"
    t.index ["format_id"], name: "index_assessment_questions_formats_on_format_id"
  end

  create_table "assessment_questions_institutions", id: :serial, force: :cascade do |t|
    t.integer "assessment_question_id"
    t.integer "institution_id"
    t.index ["assessment_question_id"], name: "index_aqs_institutions_on_assessment_question_id"
    t.index ["institution_id"], name: "index_aqs_institutions_on_institution_id"
  end

  create_table "assessment_questions_locations", id: :serial, force: :cascade do |t|
    t.integer "assessment_question_id"
    t.integer "location_id"
    t.index ["assessment_question_id"], name: "index_aqs_locations_on_assessment_question_id"
    t.index ["location_id"], name: "index_aqs_locations_on_location_id"
  end

  create_table "assessment_sections", id: :serial, force: :cascade do |t|
    t.integer "index", null: false
    t.string "name", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "assessment_id", null: false
    t.string "description", limit: 255
    t.index ["assessment_id"], name: "index_assessment_sections_on_assessment_id"
    t.index ["index"], name: "index_assessment_sections_on_index"
  end

  create_table "assessments", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255, null: false
    t.string "key", limit: 255, null: false
    t.index ["key"], name: "index_assessments_on_key"
  end

  create_table "creators", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "resource_id", null: false
    t.integer "creator_type", default: 0, null: false
    t.index ["resource_id"], name: "index_creators_on_resource_id"
  end

  create_table "extents", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.integer "resource_id", null: false
    t.index ["resource_id"], name: "index_extents_on_resource_id"
  end

  create_table "format_ink_media_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.decimal "score", precision: 4, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "format_support_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.decimal "score", precision: 4, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "formats", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.decimal "score", precision: 4, scale: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "parent_id"
    t.integer "format_class", default: 0, null: false
    t.integer "fid"
    t.string "collection_id_guide_page", limit: 255
    t.string "collection_id_guide_anchor", limit: 255
    t.string "dublin_core_format", limit: 255
    t.index ["fid"], name: "index_formats_on_fid"
    t.index ["format_class"], name: "index_formats_on_format_class"
    t.index ["parent_id"], name: "index_formats_on_parent_id"
  end

  create_table "humidity_ranges", id: :serial, force: :cascade do |t|
    t.decimal "min_rh", precision: 3
    t.decimal "max_rh", precision: 3
    t.decimal "score", precision: 4, scale: 3
    t.integer "format_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["format_id"], name: "index_humidity_ranges_on_format_id"
    t.index ["max_rh"], name: "index_humidity_ranges_on_max_rh"
    t.index ["min_rh"], name: "index_humidity_ranges_on_min_rh"
  end

  create_table "institutions", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "address1", limit: 255, null: false
    t.string "address2", limit: 255
    t.string "city", limit: 255, null: false
    t.string "state", limit: 255
    t.string "postal_code", limit: 255
    t.string "country", limit: 255, null: false
    t.string "url", limit: 255
    t.integer "language_id"
    t.text "description"
    t.string "email", limit: 255
    t.float "assessment_score", default: 0.0
    t.boolean "assessment_complete"
    t.index ["language_id"], name: "index_institutions_on_language_id"
    t.index ["name"], name: "index_institutions_on_name", unique: true
  end

  create_table "languages", id: :serial, force: :cascade do |t|
    t.string "native_name", limit: 255, null: false
    t.string "english_name", limit: 255, null: false
    t.string "iso639_2_code", limit: 255, null: false
    t.index ["english_name"], name: "index_languages_on_english_name", unique: true
    t.index ["iso639_2_code"], name: "index_languages_on_iso639_2_code", unique: true
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "repository_id", null: false
    t.text "description"
    t.integer "temperature_range_id"
    t.float "assessment_score", default: 0.0
    t.integer "humidity_range_id"
    t.boolean "assessment_complete"
    t.index ["humidity_range_id"], name: "index_locations_on_humidity_range_id"
    t.index ["repository_id"], name: "index_locations_on_repository_id"
    t.index ["temperature_range_id"], name: "index_locations_on_temperature_range_id"
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.string "key", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "index_permissions_on_key", unique: true
  end

  create_table "permissions_roles", id: :serial, force: :cascade do |t|
    t.integer "permission_id"
    t.integer "role_id"
    t.index ["permission_id"], name: "index_permissions_roles_on_permission_id"
    t.index ["role_id"], name: "index_permissions_roles_on_role_id"
  end

  create_table "repositories", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "institution_id", null: false
    t.string "name", limit: 255, null: false
    t.index ["institution_id"], name: "index_repositories_on_institution_id"
  end

  create_table "resource_dates", id: :serial, force: :cascade do |t|
    t.integer "date_type", null: false
    t.decimal "begin_year", precision: 4
    t.decimal "begin_month", precision: 2
    t.decimal "begin_day", precision: 2
    t.decimal "end_year", precision: 4
    t.decimal "end_month", precision: 2
    t.decimal "end_day", precision: 2
    t.decimal "year", precision: 4
    t.decimal "month", precision: 2
    t.decimal "day", precision: 2
    t.integer "resource_id", null: false
    t.index ["resource_id"], name: "index_resource_dates_on_resource_id"
  end

  create_table "resource_notes", id: :serial, force: :cascade do |t|
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "resource_id"
    t.index ["resource_id"], name: "index_resource_notes_on_resource_id"
  end

  create_table "resources", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "location_id", null: false
    t.integer "parent_id"
    t.integer "resource_type", null: false
    t.string "name", limit: 255, null: false
    t.integer "format_id"
    t.integer "user_id", null: false
    t.text "description"
    t.string "local_identifier", limit: 255
    t.integer "date_type"
    t.integer "assessment_id"
    t.string "rights", limit: 255
    t.integer "language_id"
    t.float "assessment_score", default: 0.0
    t.decimal "significance", precision: 2, scale: 1
    t.integer "format_ink_media_type_id"
    t.integer "format_support_type_id"
    t.integer "assessment_type"
    t.boolean "assessment_complete"
    t.index ["assessment_complete"], name: "index_resources_on_assessment_complete"
    t.index ["assessment_id"], name: "index_resources_on_assessment_id"
    t.index ["format_id"], name: "index_resources_on_format_id"
    t.index ["format_ink_media_type_id"], name: "index_resources_on_format_ink_media_type_id"
    t.index ["format_support_type_id"], name: "index_resources_on_format_support_type_id"
    t.index ["language_id"], name: "index_resources_on_language_id"
    t.index ["location_id"], name: "index_resources_on_location_id"
    t.index ["parent_id"], name: "index_resources_on_parent_id"
    t.index ["user_id"], name: "index_resources_on_user_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_admin", default: false
    t.string "name", limit: 255
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "static_pages", id: :serial, force: :cascade do |t|
    t.string "uri_fragment", limit: 255
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "html"
    t.text "searchable_html"
    t.string "category", limit: 255
    t.string "component", limit: 255
    t.index ["category"], name: "index_static_pages_on_category"
    t.index ["name"], name: "index_static_pages_on_name"
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "resource_id", null: false
    t.index ["name"], name: "index_subjects_on_name"
    t.index ["resource_id"], name: "index_subjects_on_resource_id"
  end

  create_table "temperature_ranges", id: :serial, force: :cascade do |t|
    t.decimal "min_temp_f", precision: 3
    t.decimal "max_temp_f", precision: 3
    t.decimal "score", precision: 4, scale: 3
    t.integer "format_id"
    t.index ["format_id"], name: "index_temperature_ranges_on_format_id"
    t.index ["max_temp_f"], name: "index_temperature_ranges_on_max_temp_f"
    t.index ["min_temp_f"], name: "index_temperature_ranges_on_min_temp_f"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name", limit: 255
    t.string "email", limit: 255
    t.string "last_name", limit: 255
    t.string "password_digest", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "role_id"
    t.integer "institution_id"
    t.string "username", limit: 255
    t.boolean "confirmed", default: false
    t.string "confirmation_code", limit: 255
    t.string "password_reset_key", limit: 255
    t.datetime "last_signin"
    t.boolean "enabled", default: false
    t.text "about"
    t.integer "desired_institution_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["institution_id"], name: "index_users_on_institution_id"
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "assessment_question_options", "assessment_questions"
  add_foreign_key "assessment_question_options_questions", "assessment_question_options"
  add_foreign_key "assessment_question_options_questions", "assessment_questions"
  add_foreign_key "assessment_question_responses", "assessment_question_options"
  add_foreign_key "assessment_question_responses", "assessment_questions"
  add_foreign_key "assessment_question_responses", "institutions"
  add_foreign_key "assessment_question_responses", "locations"
  add_foreign_key "assessment_question_responses", "resources"
  add_foreign_key "assessment_questions", "assessment_question_options", column: "selected_option_id"
  add_foreign_key "assessment_questions", "assessment_questions", column: "parent_id"
  add_foreign_key "assessment_questions", "assessment_sections"
  add_foreign_key "assessment_questions_formats", "assessment_questions"
  add_foreign_key "assessment_questions_formats", "formats"
  add_foreign_key "assessment_questions_institutions", "assessment_questions"
  add_foreign_key "assessment_questions_institutions", "institutions"
  add_foreign_key "assessment_questions_locations", "assessment_questions"
  add_foreign_key "assessment_questions_locations", "locations"
  add_foreign_key "assessment_sections", "assessments"
  add_foreign_key "creators", "resources"
  add_foreign_key "extents", "resources"
  add_foreign_key "formats", "formats", column: "parent_id"
  add_foreign_key "humidity_ranges", "formats"
  add_foreign_key "institutions", "languages"
  add_foreign_key "locations", "humidity_ranges"
  add_foreign_key "locations", "repositories"
  add_foreign_key "locations", "temperature_ranges"
  add_foreign_key "permissions_roles", "permissions"
  add_foreign_key "permissions_roles", "roles"
  add_foreign_key "repositories", "institutions"
  add_foreign_key "resource_dates", "resources"
  add_foreign_key "resource_notes", "resources"
  add_foreign_key "resources", "assessments"
  add_foreign_key "resources", "format_ink_media_types"
  add_foreign_key "resources", "format_support_types"
  add_foreign_key "resources", "formats"
  add_foreign_key "resources", "languages"
  add_foreign_key "resources", "locations"
  add_foreign_key "resources", "resources", column: "parent_id"
  add_foreign_key "resources", "users"
  add_foreign_key "subjects", "resources"
  add_foreign_key "temperature_ranges", "formats"
  add_foreign_key "users", "institutions"
  add_foreign_key "users", "institutions", column: "desired_institution_id"
end
