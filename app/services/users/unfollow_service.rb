# frozen_string_literal: true

module Users
  class UnfollowService < ApplicationService
    def initialize(follower, followed_user)
      super()
      @follower = follower
      @followed_user = followed_user
    end

    def call
      follow_relationship = find_follow_relationship
      raise ErrorUnprocessableEntity.new(message: 'You are not following this user') unless follow_relationship

      follow_relationship.destroy!
      follow_relationship
    end

    private

    attr_reader :follower, :followed_user

    def find_follow_relationship
      follower.active_follows.find_by(followed_user: followed_user)
    end
  end
end
