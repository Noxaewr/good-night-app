# frozen_string_literal: true

# Migration to create the sleep_records table with UUID primary key
class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.datetime :bedtime, null: false
      t.datetime :wake_time, null: false
      t.integer :duration_minutes, null: false
      t.timestamps
    end
  end
end
