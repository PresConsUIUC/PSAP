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

ActiveRecord::Schema.define(version: 20140310221816) do

  create_table "assessment_options", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assessments", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id"
  end

  add_index "assessments", ["resource_id"], name: "index_assessments_on_resource_id"

  create_table "institutions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repository_id"
  end

  add_index "locations", ["repository_id"], name: "index_locations_on_repository_id"

  create_table "permissions", force: true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
  end

  add_index "permissions", ["role_id"], name: "index_permissions_on_role_id"

  create_table "repositories", force: true do |t|
    t.integer  "institution_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.integer  "resource_id"
  end

  add_index "resources", ["location_id"], name: "index_resources_on_location_id"
  add_index "resources", ["resource_id"], name: "index_resources_on_resource_id"

  create_table "roles", force: true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",   default: false
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password_digest"
    t.integer  "institution_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
  end

  add_index "users", ["role_id"], name: "index_users_on_role_id"

end
