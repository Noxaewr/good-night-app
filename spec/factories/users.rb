# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }

    trait :with_followers do
      after(:create) do |user|
        create_list(:user, 3).each do |follower|
          create(:users_follow, follower: follower, followed_user: user)
        end
      end
    end

    trait :with_following do
      after(:create) do |user|
        create_list(:user, 3).each do |followed_user|
          create(:users_follow, follower: user, followed_user: followed_user)
        end
      end
    end

    trait :with_sleep_records do
      after(:create) do |user|
        create_list(:sleep_record, 5, user: user)
      end
    end
  end
end
