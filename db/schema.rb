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

ActiveRecord::Schema.define(:version => 20131016185523) do

  create_table "assets", :force => true do |t|
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.integer  "pin_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",   :default => 0
    t.string   "commentable_type", :default => ""
    t.string   "title",            :default => ""
    t.text     "body"
    t.string   "subject",          :default => ""
    t.integer  "user_id",          :default => 0,  :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "currency", :id => false, :force => true do |t|
    t.string  "currency", :limit => 3,                                               :null => false
    t.decimal "rate",                   :precision => 3, :scale => 0, :default => 0, :null => false
    t.string  "symbol",   :limit => 10,                                              :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "messages", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "old_users", :primary_key => "ID", :force => true do |t|
    t.string   "username",   :limit => 60
    t.string   "password",   :limit => 120
    t.string   "name",       :limit => 40,                           :null => false
    t.string   "sex",        :limit => 40,  :default => "undefined", :null => false
    t.string   "email",      :limit => 80,                           :null => false
    t.string   "Activation", :limit => 40
    t.string   "contact",    :limit => 4,   :default => "no",        :null => false
    t.string   "anonymous",  :limit => 4,   :default => "no",        :null => false
    t.integer  "numImages",                 :default => 0,           :null => false
    t.datetime "dateJoined",                                         :null => false
    t.datetime "lastLogin",                                          :null => false
    t.string   "currency",   :limit => 3,   :default => "USD",       :null => false
  end

  create_table "pin_images", :force => true do |t|
    t.string   "caption",            :limit => 555
    t.integer  "pin_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  create_table "pins", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "user_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "procedure"
    t.boolean  "revision"
    t.string   "surgeon"
    t.text     "details"
    t.integer  "cost"
    t.string   "username"
  end

  add_index "pins", ["user_id"], :name => "index_pins_on_user_id"

  create_table "results", :primary_key => "ID", :force => true do |t|
    t.string   "username",     :limit => 40,                        :null => false
    t.date     "surgeryDate"
    t.string   "surgeon",      :limit => 40,   :default => "other", :null => false
    t.string   "surgeryType",  :limit => 40,                        :null => false
    t.integer  "cost"
    t.string   "comments",     :limit => 1000
    t.string   "wantRevision", :limit => 20
    t.string   "img1",         :limit => 40
    t.string   "img2",         :limit => 40
    t.string   "img3",         :limit => 40
    t.string   "img4",         :limit => 40
    t.date     "img1date"
    t.date     "img2date"
    t.date     "img3date"
    t.date     "img4date"
    t.string   "img1com",      :limit => 400
    t.string   "img2com",      :limit => 400
    t.string   "img3com",      :limit => 400
    t.string   "img4com",      :limit => 400
    t.string   "anonymous",    :limit => 4,    :default => "no",    :null => false
    t.string   "insurance",    :limit => 4,    :default => "no",    :null => false
    t.string   "moderated",    :limit => 4,    :default => "0",     :null => false
    t.datetime "dateApproved",                                      :null => false
    t.string   "currencyCode", :limit => 3,    :default => "USD",   :null => false
  end

  create_table "surgeons", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "country"
    t.integer  "phone"
    t.string   "email"
    t.string   "url"
    t.string   "procedures"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "name"
    t.string   "gender"
    t.string   "username"
    t.boolean  "admin",                  :default => false
    t.string   "md5"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
