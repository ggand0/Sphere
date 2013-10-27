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

ActiveRecord::Schema.define(version: 20131027023440) do

  create_table "model_data", force: true do |t|
    t.string   "modeldata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "stages", force: true do |t|
    t.string   "title"
    t.string   "scene_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "textures", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.integer  "model_datum_id"
  end

end
