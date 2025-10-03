# frozen_string_literal: true

# Model for users
class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  # Following relationships
  has_many :active_follows, class_name: 'UsersFollow', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_follows, class_name: 'UsersFollow', foreign_key: 'followed_user_id', dependent: :destroy

  # Users that this user follows
  has_many :following, through: :active_follows, source: :followed_user

  # Users that follow this user
  has_many :followers, through: :passive_follows, source: :follower

  validates :name, presence: true

  # Get sleep records from all users that this user follows from the previous week
  # Returns records sorted by duration (longest first)
  def following_users_sleep_records_previous_week
    return SleepRecord.none if following.empty?

    SleepRecord.joins(:user)
               .where(user: following)
               .from_previous_week
               .ordered_by_duration
               .includes(:user)
  end

  # Paginatable version for API endpoints
  def paginated_following_sleep_records_previous_week
    following_users_sleep_records_previous_week
  end
end
