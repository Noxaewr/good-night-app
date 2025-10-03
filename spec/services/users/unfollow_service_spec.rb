# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::UnfollowService, type: :service do
  let(:follower) { create(:user) }
  let(:followed_user) { create(:user) }

  describe '#call' do
    context 'when follow relationship exists' do
      let!(:follow_relationship) { create(:users_follow, follower: follower, followed_user: followed_user) }

      it 'destroys the follow relationship' do
        expect do
          described_class.call(follower, followed_user)
        end.to change(UsersFollow, :count).by(-1)

        expect(follower.following).not_to include(followed_user)
      end

      it 'returns the destroyed follow relationship' do
        result = described_class.call(follower, followed_user)

        expect(result).to be_a(UsersFollow)
        expect(result.follower).to eq(follower)
        expect(result.followed_user).to eq(followed_user)
        expect(result).to be_destroyed
      end
    end

    context 'when follow relationship does not exist' do
      it 'raises ErrorUnprocessableEntity' do
        expect do
          described_class.call(follower, followed_user)
        end.to raise_error(ErrorUnprocessableEntity, 'You are not following this user')
      end

      it 'does not change follow relationships count' do
        expect do
          described_class.call(follower, followed_user)
        rescue ErrorUnprocessableEntity
          # Expected error
        end.not_to change(UsersFollow, :count)
      end
    end

    context 'when user never followed anyone' do
      it 'raises ErrorUnprocessableEntity' do
        expect do
          described_class.call(follower, followed_user)
        end.to raise_error(ErrorUnprocessableEntity, 'You are not following this user')
      end
    end

    context 'when database error occurs during destroy' do
      let!(:follow_relationship) { create(:users_follow, follower: follower, followed_user: followed_user) }

      before do
        allow_any_instance_of(UsersFollow).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new('Test error'))
      end

      it 'allows the error to bubble up' do
        expect do
          described_class.call(follower, followed_user)
        end.to raise_error(ActiveRecord::RecordNotDestroyed)
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
