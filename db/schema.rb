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

ActiveRecord::Schema.define(version: 20140404142615) do

  create_table "events", force: true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.integer  "user_id"
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id"

  create_table "formats", force: true do |t|
    t.string   "name"
    t.float    "score"
    t.boolean  "obsolete"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "institution_types", force: true do |t|
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
