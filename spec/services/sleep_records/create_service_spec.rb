# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SleepRecords::CreateService, type: :service do
  let(:user) { create(:user) }
  let(:valid_params) do
    {
      bedtime: 8.hours.ago,
      wake_time: Time.current
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'creates a new sleep record' do
        expect do
          described_class.call(user, valid_params)
        end.to change(SleepRecord, :count).by(1)
      end

      it 'returns the created sleep record' do
        result = described_class.call(user, valid_params)

        expect(result).to be_a(SleepRecord)
        expect(result.user).to eq(user)
        expect(result.bedtime).to be_within(1.second).of(valid_params[:bedtime])
        expect(result.wake_time).to be_within(1.second).of(valid_params[:wake_time])
      end

      it 'calculates duration correctly' do
        result = described_class.call(user, valid_params)

        expected_duration = ((valid_params[:wake_time] - valid_params[:bedtime]) / 1.minute).to_i
        expect(result.duration_minutes).to eq(expected_duration)
      end
    end

    context 'with missing bedtime' do
      let(:invalid_params) { { wake_time: Time.current } }

      it 'raises ErrorUnprocessableEntity' do
        expect do
          described_class.call(user, invalid_params)
        end.to raise_error(ErrorUnprocessableEntity, 'Bedtime is required')
      end

      it 'does not create a sleep record' do
        expect do
          described_class.call(user, invalid_params)
        rescue ErrorUnprocessableEntity
          # Expected error
        end.not_to change(SleepRecord, :count)
      end
    end

    context 'with missing wake_time' do
      let(:invalid_params) { { bedtime: 8.hours.ago } }

      it 'raises ErrorUnprocessableEntity' do
        expect do
          described_class.call(user, invalid_params)
        end.to raise_error(ErrorUnprocessableEntity, 'Wake time is required')
      end
    end

    context 'with wake_time before bedtime' do
      let(:invalid_params) do
        {
          bedtime: Time.current,
          wake_time: 1.hour.ago
        }
      end

      it 'raises ErrorUnprocessableEntity' do
        expect do
          described_class.call(user, invalid_params)
        end.to raise_error(ErrorUnprocessableEntity, 'Wake time must be after bedtime')
      end
    end

    context 'with invalid date format' do
      let(:invalid_params) do
        {
          bedtime: 'invalid-date',
          wake_time: Time.current
        }
      end

      it 'raises ErrorUnprocessableEntity' do
        expect do
          described_class.call(user, invalid_params)
        end.to raise_error(ErrorUnprocessableEntity, 'Invalid date/time format')
      end
    end

    context 'when model validation fails' do
      before do
        allow_any_instance_of(SleepRecord).to receive(:save).and_return(false)
        allow_any_instance_of(SleepRecord).to receive(:errors).and_return(
          double(full_messages: ['Some validation error'])
        )
      end

      it 'raises ErrorUnprocessableEntity with validation errors' do
        expect do
          described_class.call(user, valid_params)
        end.to raise_error(ErrorUnprocessableEntity) do |error|
          expect(error.message).to eq('Failed to create sleep record')
          expect(error.data[:errors]).to eq(['Some validation error'])
        end
      end
    end

    context 'with string datetime parameters' do
      let(:string_params) do
        {
          bedtime: '2024-01-01 22:00:00',
          wake_time: '2024-01-02 06:00:00'
        }
      end

      it 'successfully parses string datetimes' do
        result = described_class.call(user, string_params)

        expect(result).to be_persisted
        expect(result.bedtime).to eq(Time.parse(string_params[:bedtime]))
        expect(result.wake_time).to eq(Time.parse(string_params[:wake_time]))
      end
    end
  end

  describe 'service instantiation' do
    it 'cannot be instantiated directly' do
      expect do
        described_class.new(user, valid_params)
      end.to raise_error(NoMethodError)
    end

    it 'can only be called through .call class method' do
      expect(described_class).to respond_to(:call)
    end
  end
end
