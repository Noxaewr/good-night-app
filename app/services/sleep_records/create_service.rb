# frozen_string_literal: true

module SleepRecords
  class CreateService < ApplicationService
    def initialize(user, sleep_record_params)
      super()
      @user = user
      @sleep_record_params = sleep_record_params
    end

    def call
      validate_params!
      create_sleep_record
    end

    private

    attr_reader :user, :sleep_record_params

    def validate_params!
      raise ErrorUnprocessableEntity.new(message: 'Bedtime is required') if sleep_record_params[:bedtime].blank?
      raise ErrorUnprocessableEntity.new(message: 'Wake time is required') if sleep_record_params[:wake_time].blank?

      # Parse using Rails' timezone to preserve local wall time expected by specs
      @parsed_bedtime = Time.zone.parse(sleep_record_params[:bedtime].to_s)
      @parsed_wake_time = Time.zone.parse(sleep_record_params[:wake_time].to_s)

      if @parsed_wake_time <= @parsed_bedtime
        raise ErrorUnprocessableEntity.new(message: 'Wake time must be after bedtime')
      end
    rescue ArgumentError
      raise ErrorUnprocessableEntity.new(message: 'Invalid date/time format')
    end

    def create_sleep_record
      # Use parsed values to avoid implicit timezone conversions from string params
      attrs = sleep_record_params.merge(
        bedtime: @parsed_bedtime,
        wake_time: @parsed_wake_time
      )
      sleep_record = user.sleep_records.build(attrs)

      unless sleep_record.save
        raise ErrorUnprocessableEntity.new(
          message: 'Failed to create sleep record',
          data: { errors: sleep_record.errors.full_messages }
        )
      end

      sleep_record
    end
  end
end
