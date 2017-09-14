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

ActiveRecord::Schema.define(version: 20170913114700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "packages", id: :serial, force: :cascade do |t|
    t.string "repository"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stars"
    t.datetime "pushed_at"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.integer "package_id"
    t.string "version"
    t.json "package_json"
    t.json "documentation"
    t.text "readme"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "effect_manager"
    t.index ["package_id"], name: "index_versions_on_package_id"
  end

  add_foreign_key "versions", "packages"
end
