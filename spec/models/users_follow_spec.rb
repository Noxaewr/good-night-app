# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersFollow, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:follower_id) }
    it { should validate_presence_of(:followed_user_id) }
  end

  describe 'associations' do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:followed_user).class_name('User') }
  end

  describe 'uniqueness validation' do
    let(:follower) { create(:user) }
    let(:followed_user) { create(:user) }

    before do
      create(:users_follow, follower: follower, followed_user: followed_user)
    end

    it 'prevents duplicate follow relationships' do
      duplicate_follow = build(:users_follow, follower: follower, followed_user: followed_user)
      
      expect(duplicate_follow).not_to be_valid
      expect(duplicate_follow.errors[:follower_id]).to include('has already been taken')
    end
  end

  describe 'custom validations' do
    describe '#cannot_follow_self' do
      let(:user) { create(:user) }

      it 'prevents user from following themselves' do
        self_follow = build(:users_follow, follower: user, followed_user: user)
        
        expect(self_follow).not_to be_valid
        expect(self_follow.errors[:followed_user_id]).to include('cannot follow yourself')
      end

      it 'allows user to follow different user' do
        other_user = create(:user)
        follow = build(:users_follow, follower: user, followed_user: other_user)
        
        expect(follow).to be_valid
      end
    end
  end

  describe 'factory' do
    it 'creates a valid follow relationship' do
      follow = create(:users_follow)
      
      expect(follow).to be_valid
      expect(follow.follower).not_to eq(follow.followed_user)
    end
  end
end
