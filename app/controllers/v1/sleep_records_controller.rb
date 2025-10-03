# frozen_string_literal: true

module V1
  class SleepRecordsController < ApplicationController
    before_action :set_user, only: %i[index following_sleep_records create]

    # GET /v1/users/:user_id/sleep_records
    def index
      sleep_records = paginate_collection(@user.sleep_records.order(created_at: :desc))
      render_json(SleepRecordSerializer, sleep_records, {
                    meta: {
                      user_id: @user.id,
                      user_name: @user.name
                    }
                  })
    end

    # GET /v1/users/:user_id/following_sleep_records
    def following_sleep_records
      sleep_records = paginate_collection(@user.following_users_sleep_records_previous_week)
      render_json(SleepRecordSerializer, sleep_records, {
                    meta: {
                      user_id: @user.id,
                      user_name: @user.name,
                      following_count: @user.following.count
                    }
                  })
    end

    # POST /v1/users/:user_id/sleep_records
    def create
      sleep_record = SleepRecords::CreateService.call(@user, sleep_record_params)
      render_json(SleepRecordSerializer, sleep_record, { status: :created })
    end

    private

    def set_user
      @user = User.find(params[:user_id] || params[:id])
    end

    def sleep_record_params
      params.require(:sleep_record).permit(:bedtime, :wake_time)
    end
  end
end
