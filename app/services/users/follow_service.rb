# frozen_string_literal: true

module Users
  class FollowService < ApplicationService
    def initialize(follower, followed_user)
      super()
      @follower = follower
      @followed_user = followed_user
    end

    def call
      validate_follow_request!
      create_follow_relationship
    end

    private

    attr_reader :follower, :followed_user

    def validate_follow_request!
      raise ErrorUnprocessableEntity.new(message: 'You cannot follow yourself') if follower == followed_user
      raise ErrorUnprocessableEntity.new(message: 'Already following this user') if already_following?
    end

    def already_following?
      follower.active_follows.exists?(followed_user: followed_user)
    end

    def create_follow_relationship
      follower.active_follows.create!(followed_user: followed_user)
    end
  end
end
