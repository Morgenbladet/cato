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

ActiveRecord::Schema.define(version: 20160301103715) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "institutions", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.integer  "priority"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "nominations", force: :cascade do |t|
    t.integer  "institution_id"
    t.string   "name"
    t.text     "reason"
    t.string   "nominator"
    t.string   "nominator_email"
    t.boolean  "verified",        default: false
    t.integer  "votes",           default: 0
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "nominations", ["institution_id"], name: "index_nominations_on_institution_id", using: :btree

  add_foreign_key "nominations", "institutions"
end
