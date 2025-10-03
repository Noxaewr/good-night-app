# frozen_string_literal: true

# Model for sleep records
class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :bedtime, presence: true
  validates :wake_time, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }

  validate :wake_time_after_bedtime

  before_validation :calculate_duration

  scope :from_previous_week, -> { where(bedtime: 1.week.ago.beginning_of_week..1.week.ago.end_of_week) }
  scope :ordered_by_duration, -> { order(duration_minutes: :desc) }

  private

  def wake_time_after_bedtime
    return unless bedtime && wake_time

    errors.add(:wake_time, 'must be after bedtime') if wake_time <= bedtime
  end

  def calculate_duration
    return unless bedtime && wake_time

    self.duration_minutes = ((wake_time - bedtime) / 1.minute).to_i
  end
end
