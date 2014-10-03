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

ActiveRecord::Schema.define(version: 20141003222224) do

  create_table "assessment_question_options", force: true do |t|
    t.integer  "index",                                          null: false
    t.string   "name",                                           null: false
    t.decimal  "value",                  precision: 4, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_question_id",                         null: false
  end

  add_index "assessment_question_options", ["assessment_question_id"], name: "index_assessment_question_options_on_assessment_question_id"

  create_table "assessment_question_options_questions", force: true do |t|
    t.integer "assessment_question_id"
    t.integer "assessment_question_option_id"
  end

  create_table "assessment_question_responses", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id",                   null: false
    t.integer  "assessment_question_option_id"
    t.integer  "assessment_question_id",        null: false
  end

  add_index "assessment_question_responses", ["assessment_question_id"], name: "index_assessment_question_responses_on_assessment_question_id"
  add_index "assessment_question_responses", ["assessment_question_option_id"], name: "assessment_question_option_id"
  add_index "assessment_question_responses", ["resource_id"], name: "index_assessment_question_responses_on_resource_id"

  create_table "assessment_questions", force: true do |t|
    t.integer  "index",                                         null: false
    t.string   "name",                                          null: false
    t.integer  "question_type",                                 null: false
    t.decimal  "weight",                precision: 4, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_section_id",                         null: false
    t.integer  "parent_id"
    t.integer  "selected_option_id"
    t.text     "help_text"
    t.integer  "qid"
  end

  add_index "assessment_questions", ["assessment_section_id"], name: "index_assessment_questions_on_assessment_section_id"
  add_index "assessment_questions", ["parent_id"], name: "index_assessment_questions_on_parent_id"
  add_index "assessment_questions", ["selected_option_id"], name: "index_assessment_questions_on_selected_option_id"

  create_table "assessment_questions_formats", id: false, force: true do |t|
    t.integer "assessment_question_id", null: false
    t.integer "format_id",              null: false
  end

  create_table "assessment_sections", force: true do |t|
    t.integer  "index",                                 null: false
    t.string   "name",                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_id",                         null: false
    t.string   "description"
    t.decimal  "weight",        precision: 4, scale: 3, null: false
  end

  add_index "assessment_sections", ["assessment_id"], name: "index_assessment_sections_on_assessment_id"

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

  add_index "creators", ["resource_id"], name: "index_creators_on_resource_id"

  create_table "events", force: true do |t|
    t.text     "description",                                                  null: false
    t.datetime "created_at"
    t.integer  "user_id"
    t.string   "address",     limit: 45
    t.decimal  "event_level",            precision: 2, scale: 1, default: 6.0, null: false
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id"

  create_table "events_assessment_questions", id: false, force: true do |t|
    t.integer "assessment_question_id"
    t.integer "event_id"
  end

  create_table "events_assessment_sections", id: false, force: true do |t|
    t.integer "assessment_section_id"
    t.integer "event_id"
  end

  create_table "events_assessments", id: false, force: true do |t|
    t.integer "assessment_id"
    t.integer "event_id"
  end

  create_table "events_formats", id: false, force: true do |t|
    t.integer "format_id"
    t.integer "event_id"
  end

  create_table "events_institutions", id: false, force: true do |t|
    t.integer "institution_id"
    t.integer "event_id"
  end

  create_table "events_locations", id: false, force: true do |t|
    t.integer "location_id"
    t.integer "event_id"
  end

  create_table "events_repositories", id: false, force: true do |t|
    t.integer "repository_id"
    t.integer "event_id"
  end

  create_table "events_resources", id: false, force: true do |t|
    t.integer "resource_id"
    t.integer "event_id"
  end

  create_table "events_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "event_id"
  end

  create_table "extents", force: true do |t|
    t.string  "name",        null: false
    t.integer "resource_id", null: false
  end

  add_index "extents", ["resource_id"], name: "index_extents_on_resource_id"

  create_table "format_ink_media_types", force: true do |t|
    t.string   "name"
    t.decimal  "score",                  precision: 4, scale: 3, null: false
    t.integer  "group"
    t.integer  "format_id"
    t.integer  "format_vector_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "format_support_types", force: true do |t|
    t.string   "name"
    t.decimal  "score",                  precision: 4, scale: 3, null: false
    t.integer  "group"
    t.integer  "format_id"
    t.integer  "format_vector_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "format_vector_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "formats", force: true do |t|
    t.string   "name",                                             null: false
    t.decimal  "score",        precision: 4, scale: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "format_class",                         default: 0, null: false
    t.integer  "fid"
  end

  add_index "formats", ["parent_id"], name: "index_formats_on_parent_id"

  create_table "institutions", force: true do |t|
    t.string   "name",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address1",    null: false
    t.string   "address2"
    t.string   "city",        null: false
    t.string   "state",       null: false
    t.string   "postal_code", null: false
    t.string   "country",     null: false
    t.string   "url"
    t.integer  "language_id"
    t.text     "description"
    t.string   "email"
  end

  add_index "institutions", ["language_id"], name: "index_institutions_on_language_id"
  add_index "institutions", ["name"], name: "index_institutions_on_name", unique: true

  create_table "languages", force: true do |t|
    t.string "native_name",   null: false
    t.string "english_name",  null: false
    t.string "iso639_2_code", null: false
  end

  add_index "languages", ["english_name"], name: "index_languages_on_english_name", unique: true
  add_index "languages", ["iso639_2_code"], name: "index_languages_on_iso639_2_code", unique: true

  create_table "locations", force: true do |t|
    t.string   "name",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repository_id",        null: false
    t.text     "description"
    t.integer  "temperature_range_id"
  end

  add_index "locations", ["repository_id"], name: "index_locations_on_repository_id"

  create_table "permissions", force: true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["key"], name: "index_permissions_on_key", unique: true

  create_table "permissions_roles", force: true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  create_table "repositories", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "institution_id", null: false
    t.string   "name",           null: false
  end

  add_index "repositories", ["institution_id"], name: "index_repositories_on_institution_id"

  create_table "resource_dates", force: true do |t|
    t.integer "date_type",             null: false
    t.integer "begin_year",  limit: 4
    t.integer "begin_month", limit: 2
    t.integer "begin_day",   limit: 2
    t.integer "end_year",    limit: 4
    t.integer "end_month",   limit: 2
    t.integer "end_day",     limit: 2
    t.integer "year",        limit: 4
    t.integer "month",       limit: 2
    t.integer "day",         limit: 2
    t.integer "resource_id",           null: false
  end

  add_index "resource_dates", ["resource_id"], name: "index_resource_dates_on_resource_id"

  create_table "resource_notes", force: true do |t|
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id"
  end

  add_index "resource_notes", ["resource_id"], name: "index_resource_notes_on_resource_id"

  create_table "resources", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id",                                                       null: false
    t.integer  "parent_id"
    t.integer  "resource_type",                                                     null: false
    t.string   "name",                                                              null: false
    t.integer  "format_id"
    t.integer  "user_id",                                                           null: false
    t.text     "description"
    t.string   "local_identifier"
    t.integer  "date_type"
    t.string   "rights"
    t.integer  "language_id"
    t.float    "assessment_percent_complete",                         default: 0.0
    t.float    "assessment_score",                                    default: 0.0
    t.decimal  "significance",                precision: 1, scale: 1
  end

  add_index "resources", ["format_id"], name: "index_resources_on_format_id"
  add_index "resources", ["location_id"], name: "index_resources_on_location_id"
  add_index "resources", ["parent_id"], name: "index_resources_on_parent_id"
  add_index "resources", ["user_id"], name: "index_resources_on_user_id"

  create_table "roles", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",   default: false
    t.string   "name"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true

  create_table "subjects", force: true do |t|
    t.string   "name",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id", null: false
  end

  add_index "subjects", ["resource_id"], name: "index_subjects_on_resource_id"

  create_table "temperature_ranges", force: true do |t|
    t.integer "min_temp_f", limit: 3
    t.integer "max_temp_f", limit: 3
    t.decimal "score",                precision: 4, scale: 3
    t.integer "format_id"
  end

  add_index "temperature_ranges", ["format_id"], name: "index_temperature_ranges_on_format_id"

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
    t.boolean  "confirmed",            default: false
    t.string   "confirmation_code"
    t.string   "password_reset_key"
    t.datetime "last_signin"
    t.boolean  "enabled",              default: false
    t.boolean  "show_contextual_help", default: true
    t.string   "feed_key",                             null: false
    t.text     "about"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["institution_id"], name: "index_users_on_institution_id"
  add_index "users", ["role_id"], name: "index_users_on_role_id"
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
