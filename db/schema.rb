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

ActiveRecord::Schema.define(version: 20140423135746) do

  create_table "assessment_question_options", force: true do |t|
    t.integer  "index"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_question_id"
  end

  add_index "assessment_question_options", ["assessment_question_id"], name: "index_assessment_question_options_on_assessment_question_id"

  create_table "assessment_questions", force: true do |t|
    t.integer  "index"
    t.string   "name"
    t.integer  "question_type"
    t.float    "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_section_id"
    t.integer  "parent_id"
    t.integer  "selected_option_id"
    t.string   "help_text"
  end

  add_index "assessment_questions", ["assessment_section_id"], name: "index_assessment_questions_on_assessment_section_id"
  add_index "assessment_questions", ["parent_id"], name: "index_assessment_questions_on_parent_id"
  add_index "assessment_questions", ["selected_option_id"], name: "index_assessment_questions_on_selected_option_id"

  create_table "assessment_sections", force: true do |t|
    t.integer  "index"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_id"
    t.integer  "assessment_question_option_id"
  end

  add_index "assessment_sections", ["assessment_id"], name: "index_assessment_sections_on_assessment_id"
  add_index "assessment_sections", ["assessment_question_option_id"], name: "index_assessment_sections_on_assessment_question_option_id"

  create_table "assessments", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "creators", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id"
    t.integer  "creator_type", default: 0
  end

  add_index "creators", ["resource_id"], name: "index_creators_on_resource_id"

  create_table "events", force: true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.integer  "user_id"
    t.string   "address",     limit: 45
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id"

  create_table "extents", force: true do |t|
    t.string  "name"
    t.integer "resource_id"
  end

  add_index "extents", ["resource_id"], name: "index_extents_on_resource_id"

  create_table "formats", force: true do |t|
    t.string   "name"
    t.float    "score"
    t.boolean  "obsolete"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "institutions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.string   "url"
    t.integer  "language_id"
    t.text     "description"
    t.string   "email"
  end

  add_index "institutions", ["language_id"], name: "index_institutions_on_language_id"

  create_table "languages", force: true do |t|
    t.string "native_name"
    t.string "english_name"
    t.string "iso639_2_code"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repository_id"
    t.text     "description"
  end

  add_index "locations", ["repository_id"], name: "index_locations_on_repository_id"

  create_table "permissions", force: true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_roles", force: true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  create_table "repositories", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "institution_id"
    t.string   "name"
  end

  add_index "repositories", ["institution_id"], name: "index_repositories_on_institution_id"

  create_table "resource_dates", force: true do |t|
    t.integer "date_type"
    t.decimal "begin_year",  precision: 4, scale: 0
    t.decimal "begin_month", precision: 2, scale: 0
    t.decimal "begin_day",   precision: 2, scale: 0
    t.decimal "end_year",    precision: 4, scale: 0
    t.decimal "end_month",   precision: 2, scale: 0
    t.decimal "end_day",     precision: 2, scale: 0
    t.decimal "year",        precision: 4, scale: 0
    t.decimal "month",       precision: 2, scale: 0
    t.decimal "day",         precision: 2, scale: 0
    t.integer "resource_id"
  end

  add_index "resource_dates", ["resource_id"], name: "index_resource_dates_on_resource_id"

  create_table "resources", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.integer  "parent_id"
    t.integer  "resource_type"
    t.string   "name"
    t.integer  "format_id"
    t.integer  "user_id"
    t.text     "description"
    t.string   "local_identifier"
    t.text     "notes"
    t.integer  "date_type"
    t.float    "percent_complete", default: 0.0
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

  create_table "subjects", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id"
  end

  add_index "subjects", ["resource_id"], name: "index_subjects_on_resource_id"

  create_table "temperature_ranges", force: true do |t|
    t.decimal "min_temp_f", precision: 3, scale: 0
    t.decimal "max_temp_f", precision: 3, scale: 0
    t.float   "score"
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
  end

  add_index "users", ["institution_id"], name: "index_users_on_institution_id"
  add_index "users", ["role_id"], name: "index_users_on_role_id"

end
