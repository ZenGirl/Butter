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

ActiveRecord::Schema.define(:version => 20121009074654) do

  create_table "cdn_https", :force => true do |t|
    t.string   "ip_address"
    t.datetime "happened_at"
    t.string   "verb"
    t.string   "full_path"
    t.string   "http_version"
    t.integer  "status"
    t.integer  "size"
    t.string   "referrer"
    t.string   "user_agent"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "path"
  end

  add_index "cdn_https", ["happened_at", "ip_address", "full_path", "status"], :name => "by_at_ip_fpath_status"

end
