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

ActiveRecord::Schema.define(version: 20140403152110) do

  create_table "items", force: true do |t|
    t.integer  "storage_id"
    t.string   "parent_remote_id"
    t.string   "remote_id"
    t.text     "remote_link"
    t.text     "title"
    t.text     "mimeType"
    t.text     "description"
    t.datetime "createdDate"
    t.datetime "modifiedDate"
    t.integer  "userPermission"
    t.integer  "fileSize",         limit: 8
    t.text     "etag"
    t.text     "md5checksum"
    t.text     "iconLink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["parent_remote_id"], name: "index_items_on_parent_remote_id", using: :btree
  add_index "items", ["remote_id"], name: "index_items_on_remote_id", using: :btree
  add_index "items", ["storage_id"], name: "index_items_on_storage_id", using: :btree

  create_table "storages", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "token"
    t.string   "login"
    t.string   "password"
    t.string   "url"
    t.integer  "port"
    t.integer  "quota_bytes_total", limit: 8
    t.integer  "quota_bytes_used",  limit: 8
    t.text     "etag"
    t.text     "uid"
    t.text     "picture_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "storages", ["user_id"], name: "index_storages_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "salt"
    t.string   "authentication_token"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
