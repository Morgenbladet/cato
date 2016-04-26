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

ActiveRecord::Schema.define(version: 20160426113742) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "institutions", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.integer  "priority"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "nominations_count", default: 0
  end

  create_table "nominations", force: :cascade do |t|
    t.integer  "institution_id"
    t.string   "name"
    t.integer  "votes",            default: 0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "gender"
    t.integer  "year_of_birth"
    t.string   "branch"
    t.integer  "reasons_count",    default: 0
    t.boolean  "shortlisted",      default: false
    t.text     "shortlist_reason"
    t.text     "documentation"
  end

  add_index "nominations", ["institution_id"], name: "index_nominations_on_institution_id", using: :btree

  create_table "reasons", force: :cascade do |t|
    t.integer  "nomination_id"
    t.string   "nominator"
    t.text     "reason"
    t.string   "nominator_email"
    t.boolean  "verified",        default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "reasons", ["nomination_id"], name: "index_reasons_on_nomination_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "nominations", "institutions"
  add_foreign_key "reasons", "nominations"
end
