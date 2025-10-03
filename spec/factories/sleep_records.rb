# frozen_string_literal: true

FactoryBot.define do
  factory :sleep_record do
    association :user

    bedtime { 10.hours.ago }
    wake_time { 2.hours.ago }

    # Calculate duration_minutes after setting bedtime and wake_time
    after(:build) do |sleep_record|
      if sleep_record.bedtime && sleep_record.wake_time
        sleep_record.duration_minutes = ((sleep_record.wake_time - sleep_record.bedtime) / 60).to_i
      end
    end

    trait :previous_week do
      # Any time within the previous calendar week
      bedtime do
        start = 1.week.ago.beginning_of_week
        finish = 1.week.ago.end_of_week
        start + rand(0..(finish - start).to_i)
      end
      wake_time { bedtime + 8.hours }
    end

    trait :current_week do
      # Ensure within the current week window (not overlapping previous week)
      bedtime do
        start = Time.current.beginning_of_week
        span_seconds = (Time.current - start).to_i
        start + rand(0..[span_seconds, 6.days.to_i].min)
      end
      wake_time { bedtime + 8.hours }
    end

    trait :long_sleep do
      after(:build) do |sleep_record|
        sleep_record.bedtime = sleep_record.bedtime || 12.hours.ago
        sleep_record.wake_time = sleep_record.bedtime + 10.hours
        sleep_record.duration_minutes = 600 # 10 hours
      end
    end

    trait :short_sleep do
      after(:build) do |sleep_record|
        sleep_record.bedtime = sleep_record.bedtime || 6.hours.ago
        sleep_record.wake_time = sleep_record.bedtime + 5.hours
        sleep_record.duration_minutes = 300 # 5 hours
      end
    end
  end
end
