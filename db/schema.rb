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

ActiveRecord::Schema.define(:version => 20121010122546) do

  create_table "cdn_fcs", :force => true do |t|
    t.string   "mode"
    t.datetime "happened_at"
    t.string   "path"
    t.integer  "http_status"
    t.string   "ip_address"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "cdn_fcs", ["happened_at", "ip_address", "path", "http_status"], :name => "by_most"
  add_index "cdn_fcs", ["happened_at"], :name => "index_cdn_fcs_on_happened_at"
  add_index "cdn_fcs", ["http_status"], :name => "index_cdn_fcs_on_http_status"
  add_index "cdn_fcs", ["ip_address"], :name => "index_cdn_fcs_on_ip_address"
  add_index "cdn_fcs", ["mode"], :name => "index_cdn_fcs_on_mode"
  add_index "cdn_fcs", ["path"], :name => "index_cdn_fcs_on_path"

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
  add_index "cdn_https", ["happened_at"], :name => "index_cdn_https_on_happened_at"
  add_index "cdn_https", ["ip_address"], :name => "index_cdn_https_on_ip_address"

  create_table "ip_tables", :force => true do |t|
    t.integer  "from_ip",      :limit => 8
    t.integer  "to_ip",        :limit => 8
    t.string   "registry"
    t.integer  "assigned"
    t.string   "country"
    t.string   "country3"
    t.string   "country_name"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "ip_tables", ["country"], :name => "index_ip_tables_on_country"
  add_index "ip_tables", ["from_ip"], :name => "index_ip_tables_on_from"
  add_index "ip_tables", ["to_ip"], :name => "index_ip_tables_on_to"

  create_table "media_events", :force => true do |t|
    t.string   "event"
    t.string   "source"
    t.string   "media_id"
    t.string   "label"
    t.string   "label_id"
    t.integer  "user_id"
    t.string   "country"
    t.string   "upc"
    t.string   "isrc"
    t.datetime "happened_at"
    t.string   "album"
    t.string   "artist"
    t.string   "title"
    t.string   "duration"
    t.boolean  "is_sme"
    t.boolean  "is_royalty_bearing"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "media_events", ["country"], :name => "index_media_events_on_country"
  add_index "media_events", ["event"], :name => "index_media_events_on_event"
  add_index "media_events", ["happened_at"], :name => "index_media_events_on_happened_at"
  add_index "media_events", ["label"], :name => "index_media_events_on_label"
  add_index "media_events", ["media_id"], :name => "index_media_events_on_media_id"
  add_index "media_events", ["source"], :name => "index_media_events_on_source"
  add_index "media_events", ["upc"], :name => "index_media_events_on_upc"

end
