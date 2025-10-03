# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:sleep_records).dependent(:destroy) }
    it {
      should have_many(:active_follows).class_name('UsersFollow').with_foreign_key('follower_id').dependent(:destroy)
    }
    it {
      should have_many(:passive_follows).class_name('UsersFollow').with_foreign_key('followed_user_id').dependent(:destroy)
    }
    it { should have_many(:following).through(:active_follows).source(:followed_user) }
    it { should have_many(:followers).through(:passive_follows).source(:follower) }
  end

  describe '#following_users_sleep_records_previous_week' do
    let(:user) { create(:user) }
    let(:followed_user1) { create(:user) }
    let(:followed_user2) { create(:user) }
    let(:non_followed_user) { create(:user) }

    before do
      # User follows two users
      create(:users_follow, follower: user, followed_user: followed_user1)
      create(:users_follow, follower: user, followed_user: followed_user2)

      # Create sleep records for previous week
      create(:sleep_record, :previous_week, :long_sleep, user: followed_user1)
      create(:sleep_record, :previous_week, :short_sleep, user: followed_user2)

      # Create sleep records for current week (should not be included)
      create(:sleep_record, :current_week, user: followed_user1)

      # Create sleep records for non-followed user (should not be included)
      create(:sleep_record, :previous_week, user: non_followed_user)
    end

    it 'returns sleep records from followed users from previous week only' do
      records = user.following_users_sleep_records_previous_week

      expect(records.count).to eq(2)
      expect(records.map(&:user)).to contain_exactly(followed_user1, followed_user2)
    end

    it 'orders records by duration (longest first)' do
      records = user.following_users_sleep_records_previous_week

      expect(records.first.duration_minutes).to be > records.last.duration_minutes
    end

    it 'returns empty relation when user follows no one' do
      user_with_no_follows = create(:user)
      records = user_with_no_follows.following_users_sleep_records_previous_week

      expect(records).to be_empty
    end
  end

  describe 'follow relationships' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    it 'can follow another user' do
      follow = create(:users_follow, follower: user1, followed_user: user2)

      expect(user1.following).to include(user2)
      expect(user2.followers).to include(user1)
    end

    it 'can have multiple followers and following' do
      user3 = create(:user)

      create(:users_follow, follower: user1, followed_user: user2)
      create(:users_follow, follower: user1, followed_user: user3)
      create(:users_follow, follower: user2, followed_user: user1)

      expect(user1.following.count).to eq(2)
      expect(user1.followers.count).to eq(1)
    end
  end
end
