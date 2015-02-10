# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150210155207) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assessment_question_options", force: true do |t|
    t.integer  "index",                                          null: false
    t.string   "name",                                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_question_id",                         null: false
    t.decimal  "value",                  precision: 4, scale: 3
  end

  add_index "assessment_question_options", ["assessment_question_id"], name: "index_assessment_question_options_on_assessment_question_id", using: :btree

  create_table "assessment_question_options_questions", force: true do |t|
    t.integer "assessment_question_id"
    t.integer "assessment_question_option_id"
  end

  add_index "assessment_question_options_questions", ["assessment_question_id"], name: "index_aqos_questions_on_assessment_question_id", using: :btree
  add_index "assessment_question_options_questions", ["assessment_question_option_id"], name: "index_aqos_questions_on_assessment_question_option_id", using: :btree

  create_table "assessment_question_responses", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id"
    t.integer  "assessment_question_option_id"
    t.integer  "assessment_question_id",        null: false
    t.integer  "location_id"
    t.integer  "institution_id"
  end

  add_index "assessment_question_responses", ["assessment_question_id"], name: "index_assessment_question_responses_on_assessment_question_id", using: :btree
  add_index "assessment_question_responses", ["assessment_question_option_id"], name: "index_assessment_question_options", using: :btree
  add_index "assessment_question_responses", ["institution_id"], name: "index_assessment_question_responses_on_institution_id", using: :btree
  add_index "assessment_question_responses", ["location_id"], name: "index_assessment_question_responses_on_location_id", using: :btree
  add_index "assessment_question_responses", ["resource_id"], name: "index_assessment_question_responses_on_resource_id", using: :btree

  create_table "assessment_questions", force: true do |t|
    t.integer  "index",                                         null: false
    t.string   "name",                                          null: false
    t.integer  "question_type",                                 null: false
    t.decimal  "weight",                precision: 5, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_section_id",                         null: false
    t.integer  "parent_id"
    t.integer  "selected_option_id"
    t.text     "help_text"
    t.integer  "qid"
    t.string   "advanced_help_page"
    t.string   "advanced_help_anchor"
  end

  add_index "assessment_questions", ["assessment_section_id"], name: "index_assessment_questions_on_assessment_section_id", using: :btree
  add_index "assessment_questions", ["parent_id"], name: "index_assessment_questions_on_parent_id", using: :btree
  add_index "assessment_questions", ["qid"], name: "index_assessment_questions_on_qid", using: :btree
  add_index "assessment_questions", ["selected_option_id"], name: "index_assessment_questions_on_selected_option_id", using: :btree

  create_table "assessment_questions_formats", id: false, force: true do |t|
    t.integer "assessment_question_id", null: false
    t.integer "format_id",              null: false
  end

  add_index "assessment_questions_formats", ["assessment_question_id"], name: "index_assessment_questions_formats_on_assessment_question_id", using: :btree
  add_index "assessment_questions_formats", ["format_id"], name: "index_assessment_questions_formats_on_format_id", using: :btree

  create_table "assessment_questions_institutions", force: true do |t|
    t.integer "assessment_question_id"
    t.integer "institution_id"
  end

  add_index "assessment_questions_institutions", ["assessment_question_id"], name: "index_aqs_institutions_on_assessment_question_id", using: :btree
  add_index "assessment_questions_institutions", ["institution_id"], name: "index_aqs_institutions_on_institution_id", using: :btree

  create_table "assessment_questions_locations", force: true do |t|
    t.integer "assessment_question_id"
    t.integer "location_id"
  end

  add_index "assessment_questions_locations", ["assessment_question_id"], name: "index_aqs_locations_on_assessment_question_id", using: :btree
  add_index "assessment_questions_locations", ["location_id"], name: "index_aqs_locations_on_location_id", using: :btree

  create_table "assessment_sections", force: true do |t|
    t.integer  "index",         null: false
    t.string   "name",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_id", null: false
    t.string   "description"
  end

  add_index "assessment_sections", ["assessment_id"], name: "index_assessment_sections_on_assessment_id", using: :btree

  create_table "assessments", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       null: false
    t.string   "key",        null: false
  end

  create_table "creators", force: true do |t|
    t.string   "name",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id",              null: false
    t.integer  "creator_type", default: 0, null: false
  end

  add_index "creators", ["resource_id"], name: "index_creators_on_resource_id", using: :btree

  create_table "events", force: true do |t|
    t.text     "description",                                                  null: false
    t.datetime "created_at"
    t.integer  "user_id"
    t.string   "address",     limit: 45
    t.decimal  "event_level",            precision: 2, scale: 1, default: 6.0, null: false
  end

  add_index "events", ["created_at"], name: "index_events_on_created_at", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "events_assessment_questions", id: false, force: true do |t|
    t.integer "assessment_question_id"
    t.integer "event_id"
  end

  add_index "events_assessment_questions", ["assessment_question_id"], name: "index_events_aqs_on_assessment_question_id", using: :btree
  add_index "events_assessment_questions", ["event_id"], name: "index_events_aqs_on_event_id", using: :btree

  create_table "events_assessment_sections", id: false, force: true do |t|
    t.integer "assessment_section_id"
    t.integer "event_id"
  end

  add_index "events_assessment_sections", ["assessment_section_id"], name: "index_events_ass_on_ass_id", using: :btree
  add_index "events_assessment_sections", ["event_id"], name: "index_events_ass_on_event_id", using: :btree

  create_table "events_assessments", id: false, force: true do |t|
    t.integer "assessment_id"
    t.integer "event_id"
  end

  add_index "events_assessments", ["assessment_id"], name: "index_events_assessments_on_assessment_id", using: :btree
  add_index "events_assessments", ["event_id"], name: "index_events_assessments_on_event_id", using: :btree

  create_table "events_formats", id: false, force: true do |t|
    t.integer "format_id"
    t.integer "event_id"
  end

  add_index "events_formats", ["event_id"], name: "index_events_formats_on_event_id", using: :btree
  add_index "events_formats", ["format_id"], name: "index_events_formats_on_format_id", using: :btree

  create_table "events_institutions", id: false, force: true do |t|
    t.integer "institution_id"
    t.integer "event_id"
  end

  add_index "events_institutions", ["event_id"], name: "index_events_institutions_on_event_id", using: :btree
  add_index "events_institutions", ["institution_id"], name: "index_events_institutions_on_institution_id", using: :btree

  create_table "events_locations", id: false, force: true do |t|
    t.integer "location_id"
    t.integer "event_id"
  end

  add_index "events_locations", ["event_id"], name: "index_events_locations_on_event_id", using: :btree
  add_index "events_locations", ["location_id"], name: "index_events_locations_on_location_id", using: :btree

  create_table "events_repositories", id: false, force: true do |t|
    t.integer "repository_id"
    t.integer "event_id"
  end

  add_index "events_repositories", ["event_id"], name: "index_events_repositories_on_event_id", using: :btree
  add_index "events_repositories", ["repository_id"], name: "index_events_repositories_on_repository_id", using: :btree

  create_table "events_resources", id: false, force: true do |t|
    t.integer "resource_id"
    t.integer "event_id"
  end

  add_index "events_resources", ["event_id"], name: "index_events_resources_on_event_id", using: :btree
  add_index "events_resources", ["resource_id"], name: "index_events_resources_on_resource_id", using: :btree

  create_table "events_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "event_id"
  end

  add_index "events_users", ["event_id"], name: "index_events_users_on_event_id", using: :btree
  add_index "events_users", ["user_id"], name: "index_events_users_on_user_id", using: :btree

  create_table "extents", force: true do |t|
    t.string  "name",        null: false
    t.integer "resource_id", null: false
  end

  add_index "extents", ["resource_id"], name: "index_extents_on_resource_id", using: :btree

  create_table "format_ink_media_types", force: true do |t|
    t.string   "name"
    t.decimal  "score",      precision: 4, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "format_support_types", force: true do |t|
    t.string   "name"
    t.decimal  "score",      precision: 4, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "formats", force: true do |t|
    t.string   "name",                                                       null: false
    t.decimal  "score",                  precision: 4, scale: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "format_class",                                   default: 0, null: false
    t.integer  "fid"
    t.string   "format_id_guide_page"
    t.string   "format_id_guide_anchor"
    t.string   "dublin_core_format"
  end

  add_index "formats", ["fid"], name: "index_formats_on_fid", using: :btree
  add_index "formats", ["parent_id"], name: "index_formats_on_parent_id", using: :btree

  create_table "humidity_ranges", force: true do |t|
    t.decimal  "min_rh",     precision: 3, scale: 0
    t.decimal  "max_rh",     precision: 3, scale: 0
    t.decimal  "score",      precision: 4, scale: 3
    t.integer  "format_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "humidity_ranges", ["format_id"], name: "index_humidity_ranges_on_format_id", using: :btree
  add_index "humidity_ranges", ["max_rh"], name: "index_humidity_ranges_on_max_rh", using: :btree
  add_index "humidity_ranges", ["min_rh"], name: "index_humidity_ranges_on_min_rh", using: :btree

  create_table "institutions", force: true do |t|
    t.string   "name",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address1",                          null: false
    t.string   "address2"
    t.string   "city",                              null: false
    t.string   "state"
    t.string   "postal_code"
    t.string   "country",                           null: false
    t.string   "url"
    t.integer  "language_id"
    t.text     "description"
    t.string   "email"
    t.float    "assessment_score",    default: 0.0
    t.boolean  "assessment_complete"
  end

  add_index "institutions", ["language_id"], name: "index_institutions_on_language_id", using: :btree
  add_index "institutions", ["name"], name: "index_institutions_on_name", unique: true, using: :btree

  create_table "languages", force: true do |t|
    t.string "native_name",   null: false
    t.string "english_name",  null: false
    t.string "iso639_2_code", null: false
  end

  add_index "languages", ["english_name"], name: "index_languages_on_english_name", unique: true, using: :btree
  add_index "languages", ["iso639_2_code"], name: "index_languages_on_iso639_2_code", unique: true, using: :btree

  create_table "locations", force: true do |t|
    t.string   "name",                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repository_id",                      null: false
    t.text     "description"
    t.integer  "temperature_range_id"
    t.float    "assessment_score",     default: 0.0
    t.integer  "humidity_range_id"
    t.boolean  "assessment_complete"
  end

  add_index "locations", ["humidity_range_id"], name: "index_locations_on_humidity_range_id", using: :btree
  add_index "locations", ["repository_id"], name: "index_locations_on_repository_id", using: :btree
  add_index "locations", ["temperature_range_id"], name: "index_locations_on_temperature_range_id", using: :btree

  create_table "permissions", force: true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["key"], name: "index_permissions_on_key", unique: true, using: :btree

  create_table "permissions_roles", force: true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  add_index "permissions_roles", ["permission_id"], name: "index_permissions_roles_on_permission_id", using: :btree
  add_index "permissions_roles", ["role_id"], name: "index_permissions_roles_on_role_id", using: :btree

  create_table "repositories", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "institution_id", null: false
    t.string   "name",           null: false
  end

  add_index "repositories", ["institution_id"], name: "index_repositories_on_institution_id", using: :btree

  create_table "resource_dates", force: true do |t|
    t.integer "date_type",                           null: false
    t.decimal "begin_year",  precision: 4, scale: 0
    t.decimal "begin_month", precision: 2, scale: 0
    t.decimal "begin_day",   precision: 2, scale: 0
    t.decimal "end_year",    precision: 4, scale: 0
    t.decimal "end_month",   precision: 2, scale: 0
    t.decimal "end_day",     precision: 2, scale: 0
    t.decimal "year",        precision: 4, scale: 0
    t.decimal "month",       precision: 2, scale: 0
    t.decimal "day",         precision: 2, scale: 0
    t.integer "resource_id",                         null: false
  end

  add_index "resource_dates", ["resource_id"], name: "index_resource_dates_on_resource_id", using: :btree

  create_table "resource_notes", force: true do |t|
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id"
  end

  add_index "resource_notes", ["resource_id"], name: "index_resource_notes_on_resource_id", using: :btree

  create_table "resources", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id",                                                    null: false
    t.integer  "parent_id"
    t.integer  "resource_type",                                                  null: false
    t.string   "name",                                                           null: false
    t.integer  "format_id"
    t.integer  "user_id",                                                        null: false
    t.text     "description"
    t.string   "local_identifier"
    t.integer  "date_type"
    t.integer  "assessment_id"
    t.string   "rights"
    t.integer  "language_id"
    t.float    "assessment_score",                                 default: 0.0
    t.decimal  "significance",             precision: 2, scale: 1
    t.integer  "format_ink_media_type_id"
    t.integer  "format_support_type_id"
    t.integer  "assessment_type"
    t.boolean  "assessment_complete"
  end

  add_index "resources", ["assessment_id"], name: "index_resources_on_assessment_id", using: :btree
  add_index "resources", ["format_id"], name: "index_resources_on_format_id", using: :btree
  add_index "resources", ["format_ink_media_type_id"], name: "index_resources_on_format_ink_media_type_id", using: :btree
  add_index "resources", ["format_support_type_id"], name: "index_resources_on_format_support_type_id", using: :btree
  add_index "resources", ["language_id"], name: "index_resources_on_language_id", using: :btree
  add_index "resources", ["location_id"], name: "index_resources_on_location_id", using: :btree
  add_index "resources", ["parent_id"], name: "index_resources_on_parent_id", using: :btree
  add_index "resources", ["user_id"], name: "index_resources_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",   default: false
    t.string   "name"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree

  create_table "static_pages", force: true do |t|
    t.string   "uri_fragment"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "html"
    t.text     "searchable_html"
    t.string   "category"
  end

  add_index "static_pages", ["category"], name: "index_static_pages_on_category", using: :btree
  add_index "static_pages", ["name"], name: "index_static_pages_on_name", using: :btree

  create_table "subjects", force: true do |t|
    t.string   "name",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id", null: false
  end

  add_index "subjects", ["name"], name: "index_subjects_on_name", using: :btree
  add_index "subjects", ["resource_id"], name: "index_subjects_on_resource_id", using: :btree

  create_table "temperature_ranges", force: true do |t|
    t.decimal "min_temp_f", precision: 3, scale: 0
    t.decimal "max_temp_f", precision: 3, scale: 0
    t.decimal "score",      precision: 4, scale: 3
    t.integer "format_id"
  end

  add_index "temperature_ranges", ["format_id"], name: "index_temperature_ranges_on_format_id", using: :btree
  add_index "temperature_ranges", ["max_temp_f"], name: "index_temperature_ranges_on_max_temp_f", using: :btree
  add_index "temperature_ranges", ["min_temp_f"], name: "index_temperature_ranges_on_min_temp_f", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "email"
    t.string   "last_name"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
    t.integer  "institution_id"
    t.string   "username"
    t.boolean  "confirmed",              default: false
    t.string   "confirmation_code"
    t.string   "password_reset_key"
    t.datetime "last_signin"
    t.boolean  "enabled",                default: false
    t.string   "feed_key",                               null: false
    t.text     "about"
    t.integer  "desired_institution_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["institution_id"], name: "index_users_on_institution_id", using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
