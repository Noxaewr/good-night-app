# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_01_030000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "sleep_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "bedtime", null: false
    t.datetime "wake_time", null: false
    t.integer "duration_minutes", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bedtime", "duration_minutes"], name: "index_sleep_records_on_bedtime_and_duration_minutes"
    t.index ["bedtime"], name: "index_sleep_records_on_bedtime"
    t.index ["created_at"], name: "index_sleep_records_on_created_at"
    t.index ["duration_minutes"], name: "index_sleep_records_on_duration_minutes"
    t.index ["user_id", "bedtime"], name: "index_sleep_records_on_user_id_and_bedtime"
    t.index ["user_id"], name: "index_sleep_records_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_users_on_id", unique: true
  end

  create_table "users_follows", force: :cascade do |t|
    t.uuid "follower_id", null: false
    t.uuid "followed_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_user_id"], name: "index_users_follows_on_followed_user_id"
    t.index ["follower_id", "followed_user_id"], name: "index_users_follows_on_follower_id_and_followed_user_id", unique: true
    t.index ["follower_id"], name: "index_users_follows_on_follower_id"
  end

  add_foreign_key "sleep_records", "users"
  add_foreign_key "users_follows", "users", column: "followed_user_id"
  add_foreign_key "users_follows", "users", column: "follower_id"
end
