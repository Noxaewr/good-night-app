# frozen_string_literal: true

FactoryBot.define do
  factory :users_follow do
    association :follower, factory: :user
    association :followed_user, factory: :user
  end
end
