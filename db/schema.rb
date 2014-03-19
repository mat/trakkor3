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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140319094017) do

  create_table "logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  create_table "pieces", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tracker_id"
    t.integer  "bytecount"
    t.float    "duration"
    t.text     "text"
  end

  add_index "pieces", ["tracker_id", "created_at"], :name => "pieces_tracker_id_idx"
  add_index "pieces", ["tracker_id"], :name => "pieces_tracker_error"

  create_table "trackers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uri"
    t.string   "xpath"
    t.string   "name"
    t.string   "md5sum"
    t.text     "web_hook"
    t.integer  "error_count", :default => 0
    t.text     "last_error",  :default => ""
  end

  add_index "trackers", ["id"], :name => "unique_trackers_tracker_id", :unique => true

end
