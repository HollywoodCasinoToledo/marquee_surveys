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

ActiveRecord::Schema.define(version: 20180329175025) do

  create_table "admins", force: :cascade do |t|
    t.integer  "property_id",     limit: 4, null: false
    t.integer  "IDnum",           limit: 4, null: false
    t.integer  "password_digest", limit: 4, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "answers", force: :cascade do |t|
    t.integer  "question_id", limit: 4,   null: false
    t.string   "title",       limit: 255, null: false
    t.string   "picture",     limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "value",       limit: 4
  end

  create_table "categories", force: :cascade do |t|
    t.integer  "property_id", limit: 4,   null: false
    t.integer  "survey_id",   limit: 4,   null: false
    t.string   "name",        limit: 255, null: false
    t.integer  "parent",      limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "patron_id",   limit: 4
    t.integer  "question_id", limit: 4
    t.text     "comment",     limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "instance_id", limit: 255
  end

  create_table "patrons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "properties", force: :cascade do |t|
    t.integer  "code",            limit: 4,                         null: false
    t.string   "name",            limit: 255,                       null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "password_digest", limit: 255, default: "Hollywood"
  end

  create_table "questions", force: :cascade do |t|
    t.integer  "survey_id",   limit: 4,                   null: false
    t.string   "title",       limit: 255,                 null: false
    t.string   "style",       limit: 4
    t.boolean  "multiple",                default: false
    t.boolean  "required",                default: false
    t.integer  "parent",      limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "category_id", limit: 4
    t.integer  "next_id",     limit: 4
    t.integer  "position",    limit: 4
    t.boolean  "active",                  default: true
  end

  create_table "responses", force: :cascade do |t|
    t.integer  "patron_id",   limit: 4
    t.integer  "question_id", limit: 4
    t.integer  "answer_id",   limit: 4,   null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "instance_id", limit: 255
  end

  create_table "surveys", force: :cascade do |t|
    t.integer  "property_id", limit: 4,   null: false
    t.string   "name",        limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

end
