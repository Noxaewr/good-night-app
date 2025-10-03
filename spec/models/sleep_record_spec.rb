# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:bedtime) }
    it { should validate_presence_of(:wake_time) }
    it { should validate_presence_of(:duration_minutes) }
    it { should validate_numericality_of(:duration_minutes).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'custom validations' do
    let(:user) { create(:user) }

    it 'validates wake_time is after bedtime' do
      sleep_record = build(:sleep_record,
                           user: user,
                           bedtime: Time.current,
                           wake_time: Time.current - 1.hour)

      expect(sleep_record).not_to be_valid
      expect(sleep_record.errors[:wake_time]).to include('must be after bedtime')
    end

    it 'is valid when wake_time is after bedtime' do
      sleep_record = build(:sleep_record,
                           user: user,
                           bedtime: Time.current - 8.hours,
                           wake_time: Time.current)

      expect(sleep_record).to be_valid
    end
  end

  describe 'callbacks' do
    describe '#calculate_duration' do
      let(:user) { create(:user) }
      let(:bedtime) { Time.current - 8.hours }
      let(:wake_time) { Time.current }

      it 'calculates duration_minutes before save' do
        sleep_record = build(:sleep_record,
                             user: user,
                             bedtime: bedtime,
                             wake_time: wake_time)

        sleep_record.save!

        expected_duration = ((wake_time - bedtime) / 1.minute).to_i
        expect(sleep_record.duration_minutes).to eq(expected_duration)
      end

      it 'updates duration when times change' do
        sleep_record = create(:sleep_record, user: user)
        original_duration = sleep_record.duration_minutes

        sleep_record.update!(wake_time: sleep_record.wake_time + 1.hour)

        expect(sleep_record.duration_minutes).to eq(original_duration + 60)
      end
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }

    describe '.from_previous_week' do
      before do
        # Previous week records
        create(:sleep_record, :previous_week, user: user)
        create(:sleep_record, :previous_week, user: user)

        # Current week records
        create(:sleep_record, :current_week, user: user)
      end

      it 'returns only records from previous week' do
        records = SleepRecord.from_previous_week

        expect(records.count).to eq(2)
        records.each do |record|
          expect(record.bedtime).to be_between(1.week.ago.beginning_of_week, 1.week.ago.end_of_week)
        end
      end
    end

    describe '.ordered_by_duration' do
      before do
        create(:sleep_record, :long_sleep, user: user)
        create(:sleep_record, :short_sleep, user: user)
      end

      it 'orders records by duration in descending order' do
        records = SleepRecord.ordered_by_duration

        expect(records.first.duration_minutes).to be > records.last.duration_minutes
      end
    end
  end

  describe 'factory' do
    it 'creates a valid sleep record' do
      sleep_record = create(:sleep_record)

      expect(sleep_record).to be_valid
      expect(sleep_record.wake_time).to be > sleep_record.bedtime
      expect(sleep_record.duration_minutes).to be > 0
    end

    it 'creates previous week sleep record with trait' do
      sleep_record = create(:sleep_record, :previous_week)

      expect(sleep_record.bedtime).to be_between(1.week.ago.beginning_of_week, 1.week.ago.end_of_week)
    end
  end
end
