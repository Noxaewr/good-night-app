class SleepRecordSerializer < ApplicationSerializer
  attributes :id, :bedtime, :wake_time, :duration_minutes, :created_at

  attribute :user_id do |object|
    object.user.id
  end

  attribute :user_name do |object|
    object.user.name
  end

  attribute :duration_hours do |object|
    (object.duration_minutes / 60.0).round(2)
  end

  # For sleep records with additional user context
  def self.with_user_context(user, sleep_records)
    {
      user_id: user.id,
      user_name: user.name,
      following_count: user.following.count,
      sleep_records: new(sleep_records, is_collection: true).serializable_hash[:data].map { |record| record[:attributes] },
      total_records: sleep_records.count
    }
  end
end
