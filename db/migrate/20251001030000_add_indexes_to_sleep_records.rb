# frozen_string_literal: true

class AddIndexesToSleepRecords < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records, :bedtime
    add_index :sleep_records, :duration_minutes
    add_index :sleep_records, :created_at
    add_index :sleep_records, %i[user_id bedtime]
    add_index :sleep_records, %i[bedtime duration_minutes]
  end
end
