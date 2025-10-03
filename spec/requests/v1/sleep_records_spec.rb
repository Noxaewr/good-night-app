# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/sleep_records' do
  let!(:user) { create(:user) }

  describe 'GET /v1/users/{user_id}/sleep_records' do
    path '/v1/users/{user_id}/sleep_records' do
      get 'List user sleep records' do
        tags 'Sleep Records'
        consumes 'application/json'
        parameter name: 'user_id', in: :path, type: :string, description: 'User ID'
        parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
        parameter name: :per_page, in: :query, type: :integer, description: 'Items per page', required: false

        response '200', 'successful' do
          context 'with valid user and sleep records' do
            before { create_list(:sleep_record, 20, user: user) }

            let(:user_id) { user.id }
            let(:page) { 1 }
            let(:per_page) { 10 }

            run_test! do |response|
              expect(response).to have_http_status(:ok)
              json_response = response.parsed_body
              expect(json_response['data']).to be_an(Array)
              expect(json_response['data'].length).to eq(10)
              expect(json_response['meta']['pagination']['total_items']).to eq(20)
              expect(json_response['meta']['user_id']).to eq(user.id)
            end
          end
        end

        response '404', 'user not found' do
          context 'with non-existent user' do
            let(:user_id) { 'non-existent' }

            run_test! do |response|
              expect(response).to have_http_status(:not_found)
              json_response = response.parsed_body
              expect(json_response['error']).to be_present
            end
          end
        end
      end
    end
  end

  describe 'POST /v1/users/{user_id}/sleep_records' do
    path '/v1/users/{user_id}/sleep_records' do
      post 'Create sleep record' do
        tags 'Sleep Records'
        consumes 'application/json'
        produces 'application/json'
        parameter name: 'user_id', in: :path, type: :string, description: 'User ID'
        parameter name: :sleep_record_params, in: :body, schema: {
          type: :object,
          properties: {
            sleep_record: {
              type: :object,
              properties: {
                bedtime: { type: :string, format: 'date-time', example: '2023-10-01T22:00:00Z' },
                wake_time: { type: :string, format: 'date-time', example: '2023-10-02T06:00:00Z' }
              },
              required: %w[bedtime wake_time]
            }
          },
          required: %w[sleep_record]
        }

        response '201', 'sleep record created' do
          context 'with valid parameters' do
            let(:user_id) { user.id }
            let(:sleep_record_params) do
              {
                sleep_record: {
                  bedtime: 8.hours.ago.iso8601,
                  wake_time: Time.current.iso8601
                }
              }
            end

            run_test! do |response|
              expect(response).to have_http_status(:created)
              json_response = response.parsed_body
              expect(json_response['data']['attributes']).to have_key('duration_minutes')
              expect(json_response['data']['attributes']).to have_key('bedtime')
              expect(json_response['data']['attributes']).to have_key('wake_time')
            end
          end
        end

        response '422', 'validation failed' do
          context 'with invalid time order' do
            let(:user_id) { user.id }
            let(:sleep_record_params) do
              {
                sleep_record: {
                  bedtime: Time.current.iso8601,
                  wake_time: 1.hour.ago.iso8601
                }
              }
            end

            run_test! do |response|
              expect(response).to have_http_status(:unprocessable_content)
            end
          end
        end

        response '404', 'user not found' do
          context 'with non-existent user' do
            let(:user_id) { 'non-existent' }
            let(:sleep_record_params) do
              {
                sleep_record: {
                  bedtime: 8.hours.ago.iso8601,
                  wake_time: Time.current.iso8601
                }
              }
            end

            run_test! do |response|
              expect(response).to have_http_status(:not_found)
              json_response = response.parsed_body
              expect(json_response['error']).to be_present
            end
          end
        end
      end
    end
  end

  describe 'GET /v1/users/{user_id}/following_sleep_records' do
    path '/v1/users/{user_id}/following_sleep_records' do
      get 'List following users sleep records' do
        tags 'Sleep Records'
        consumes 'application/json'
        parameter name: 'user_id', in: :path, type: :string, description: 'User ID'
        parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
        parameter name: :per_page, in: :query, type: :integer, description: 'Items per page', required: false

        response '200', 'successful' do
          context 'with following users having sleep records' do
            before do
              followed_user1 = create(:user)
              followed_user2 = create(:user)
              non_followed_user = create(:user)

              # User follows two users
              create(:users_follow, follower: user, followed_user: followed_user1)
              create(:users_follow, follower: user, followed_user: followed_user2)

              # Create sleep records for previous week
              create_list(:sleep_record, 5, :previous_week, user: followed_user1)
              create_list(:sleep_record, 3, :previous_week, user: followed_user2)

              # Create sleep records for current week (should not be included)
              create(:sleep_record, :current_week, user: followed_user1)

              # Create sleep records for non-followed user (should not be included)
              create(:sleep_record, :previous_week, user: non_followed_user)
            end

            let(:user_id) { user.id }
            let(:page) { 1 }
            let(:per_page) { 5 }

            run_test! do |response|
              expect(response).to have_http_status(:ok)
              json_response = response.parsed_body
              expect(json_response['data'].length).to eq(5)
              expect(json_response['meta']['user_id']).to eq(user.id)
              expect(json_response['meta']['following_count']).to eq(2)

              # Verify ordering by duration (longest first)
              durations = json_response['data'].map { |record| record['attributes']['duration_minutes'] }
              expect(durations).to eq(durations.sort.reverse)

              # Verify only previous week records
              json_response['data'].each do |record|
                bedtime = Time.parse(record['attributes']['bedtime'])
                expect(bedtime).to be_between(1.week.ago.beginning_of_week, 1.week.ago.end_of_week)
              end
            end
          end
        end

        response '404', 'user not found' do
          context 'with non-existent user' do
            let(:user_id) { 'non-existent' }

            run_test! do |response|
              expect(response).to have_http_status(:not_found)
              json_response = response.parsed_body
              expect(json_response['error']).to be_present
            end
          end
        end
      end
    end
  end
end
