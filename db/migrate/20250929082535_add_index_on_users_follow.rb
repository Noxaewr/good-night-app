# frozen_string_literal: true

# Migration to add index on users_follows table
class AddIndexOnUsersFollow < ActiveRecord::Migration[8.0]
  def change
    add_index :users_follows, %i[follower_id followed_user_id],
              unique: true,
              name: 'index_users_follows_on_follower_id_and_followed_user_id'
  end
end
