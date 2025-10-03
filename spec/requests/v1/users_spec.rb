# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'V1::Users API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  path '/v1/users' do
    get('List all users') do
      tags 'Users'
      description 'Retrieve a paginated list of all users'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Items per page (max 100)', required: false

      response(200, 'successful') do
        before { create_list(:user, 15) }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test! do |response|
          data = response.parsed_body
          expect(data['data']).to be_an(Array)
          expect(data['data'].length).to eq(10)
          expect(data['meta']['pagination']['current_page']).to eq(1)
          expect(data['meta']['pagination']['total_items']).to eq(15)
        end
      end
    end

    post('Create a new user') do
      tags 'Users'
      description 'Create a new user account'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'John Doe' }
            },
            required: %w[name]
          }
        },
        required: %w[user]
      }

      response(201, 'user created') do
        let(:user) { { user: { name: 'John Doe' } } }

        run_test! do |response|
          data = response.parsed_body
          expect(data['data']['attributes']['name']).to eq('John Doe')
        end
      end

      response(422, 'validation failed') do
        let(:user) { { user: { name: '' } } }

        run_test!
      end

      response(400, 'bad request') do
        let(:user) { {} }

        run_test!
      end
    end
  end

  path '/v1/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'User ID'

    get('Show user details') do
      tags 'Users'
      description 'Get details for a specific user'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { user.id }

        run_test! do |response|
          data = response.parsed_body
          expect(data['data']['id']).to eq(user.id)
          expect(data['data']['attributes']['name']).to eq(user.name)
        end
      end

      response(404, 'user not found') do
        let(:id) { 'non-existent' }

        run_test!
      end
    end
  end

  path '/v1/users/{id}/follow' do
    parameter name: 'id', in: :path, type: :string, description: 'User ID'

    post('Follow a user') do
      tags 'Users'
      description 'Follow another user'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :follow_params, in: :body, schema: {
        type: :object,
        properties: {
          target_user_id: { type: :string, format: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' }
        },
        required: %w[target_user_id]
      }

      response(201, 'successfully followed') do
        let(:id) { user.id }
        let(:follow_params) { { target_user_id: other_user.id } }

        run_test! do |response|
          data = response.parsed_body
          expect(data['data']['attributes']['message']).to include('Successfully followed')
          user.reload
          expect(user.following).to include(other_user)
        end
      end

      response(422, 'cannot follow') do
        let(:id) { user.id }
        let(:follow_params) { { target_user_id: user.id } }

        run_test!
      end

      response(404, 'user not found') do
        let(:id) { 'non-existent' }
        let(:follow_params) { { target_user_id: other_user.id } }

        run_test!
      end
    end
  end

  path '/v1/users/{id}/unfollow' do
    delete('Unfollow a user') do
      tags 'Users'
      description 'Unfollow a previously followed user'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :string, description: 'User ID'
      parameter name: :unfollow_params, in: :body, schema: {
        type: :object,
        properties: {
          target_user_id: { type: :string, format: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' }
        },
        required: %w[target_user_id]
      }

      response(200, 'successfully unfollowed') do
        before { create(:users_follow, follower: user, followed_user: other_user) }

        let(:id) { user.id }
        let(:unfollow_params) { { target_user_id: other_user.id } }

        run_test! do |response|
          data = response.parsed_body
          expect(data['data']['attributes']['message']).to include('Successfully unfollowed')
          user.reload
          expect(user.following).not_to include(other_user)
        end
      end

      response(422, 'not following user') do
        let(:different_user) { create(:user) }
        let(:id) { user.id }
        let(:unfollow_params) { { target_user_id: different_user.id } }

        run_test!
      end
    end
  end

  path '/v1/users/{id}/following' do
    get('List users being followed') do
      tags 'Users'
      description 'Get paginated list of users that this user follows'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :string, description: 'User ID'
      parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Items per page', required: false

      response(200, 'successful') do
        before do
          followed_users = create_list(:user, 12)
          followed_users.each do |followed_user|
            create(:users_follow, follower: user, followed_user: followed_user)
          end
        end

        let(:id) { user.id }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test! do |response|
          data = response.parsed_body
          expect(data['data'].length).to eq(10)
          expect(data['meta']['user_id']).to eq(user.id)
          expect(data['meta']['following_count']).to eq(12)
        end
      end
    end
  end

  path '/v1/users/{id}/followers' do
    get('List followers') do
      tags 'Users'
      description 'Get paginated list of users that follow this user'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :string, description: 'User ID'
      parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Items per page', required: false

      response(200, 'successful') do
        before do
          followers = create_list(:user, 8)
          followers.each do |follower|
            create(:users_follow, follower: follower, followed_user: user)
          end
        end

        let(:id) { user.id }
        let(:page) { 1 }
        let(:per_page) { 5 }

        run_test! do |response|
          data = response.parsed_body
          expect(data['data'].length).to eq(5)
          expect(data['meta']['user_id']).to eq(user.id)
          expect(data['meta']['followers_count']).to eq(8)
        end
      end
    end
  end
end
