# frozen_string_literal: true

# Migration to create the users_follows table
class CreateUsersFollow < ActiveRecord::Migration[8.0]
  def change
    create_table :users_follows do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :followed_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.timestamps
    end
  end
end
