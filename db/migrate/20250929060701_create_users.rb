# frozen_string_literal: true

# Migration to create the users table with UUID primary key
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :users, :id, unique: true, name: 'index_users_on_id'
  end
end
