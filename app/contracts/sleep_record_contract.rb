# frozen_string_literal: true

class SleepRecordContract < ApplicationContract
  params do
    required(:bedtime).filled(:date_time)
    required(:wake_time).filled(:date_time)
  end

  rule(:bedtime, :wake_time) do
    if values[:bedtime] && values[:wake_time] && (values[:wake_time] <= values[:bedtime])
      key.failure('wake_time must be after bedtime')
    end
  end

  rule(:bedtime) do
    key.failure('bedtime cannot be in the future') if value && (value > Time.current)
  end

  rule(:wake_time) do
    key.failure('wake_time cannot be in the future') if value && (value > Time.current)
  end
end
