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

ActiveRecord::Schema[8.0].define(version: 20_250_929_082_535) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pg_catalog.plpgsql'

  create_table 'users', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'name', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['id'], name: 'index_users_on_id', unique: true
  end

  create_table 'users_follows', force: :cascade do |t|
    t.bigint 'follower_id', null: false
    t.bigint 'followed_user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['followed_user_id'], name: 'index_users_follows_on_followed_user_id'
    t.index %w[follower_id followed_user_id], name: 'index_users_follows_on_follower_id_and_followed_user_id',
                                              unique: true
    t.index ['follower_id'], name: 'index_users_follows_on_follower_id'
  end
end
