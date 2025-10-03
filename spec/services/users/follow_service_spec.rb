# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::FollowService, type: :service do
  let(:follower) { create(:user) }
  let(:followed_user) { create(:user) }

  describe '#call' do
    context 'with valid users' do
      it 'creates a follow relationship' do
        expect do
          described_class.call(follower, followed_user)
        end.to change(UsersFollow, :count).by(1)

        expect(follower.following).to include(followed_user)
      end

      it 'returns the created follow relationship' do
        result = described_class.call(follower, followed_user)

        expect(result).to be_a(UsersFollow)
        expect(result.follower).to eq(follower)
        expect(result.followed_user).to eq(followed_user)
      end
    end

    context 'when trying to follow yourself' do
      it 'raises ErrorUnprocessableEntity' do
        expect do
          described_class.call(follower, follower)
        end.to raise_error(ErrorUnprocessableEntity, 'You cannot follow yourself')
      end

      it 'does not create a follow relationship' do
        expect do
          described_class.call(follower, follower)
        rescue ErrorUnprocessableEntity
          # Expected error
        end.not_to change(UsersFollow, :count)
      end
    end

    context 'when already following the user' do
      before do
        create(:users_follow, follower: follower, followed_user: followed_user)
      end

      it 'raises ErrorUnprocessableEntity' do
        expect do
          described_class.call(follower, followed_user)
        end.to raise_error(ErrorUnprocessableEntity, 'Already following this user')
      end

      it 'does not create duplicate follow relationship' do
        expect do
          described_class.call(follower, followed_user)
        rescue ErrorUnprocessableEntity
          # Expected error
        end.not_to change(UsersFollow, :count)
      end
    end

    context 'when database error occurs' do
      before do
        allow(follower.active_follows).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(UsersFollow.new))
      end

      it 'allows the error to bubble up' do
        expect do
          described_class.call(follower, followed_user)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'service instantiation' do
    it 'cannot be instantiated directly' do
      expect do
        described_class.new(follower, followed_user)
      end.to raise_error(NoMethodError)
    end

    it 'can only be called through .call class method' do
      expect(described_class).to respond_to(:call)
    end
  end
end
