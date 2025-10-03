class UnfollowSuccessSerializer < ApplicationSerializer
  set_id { |_| 'unfollow_success' }
  set_type :unfollow_success
  attribute :message do |object|
    "Successfully unfollowed #{object[:unfollowed_user].name}"
  end

  attribute :follower do |object|
    {
      id: object[:follower].id,
      name: object[:follower].name
    }
  end

  attribute :unfollowed_user do |object|
    {
      id: object[:unfollowed_user].id,
      name: object[:unfollowed_user].name
    }
  end

  attribute :following_count do |object|
    object[:follower].following.count
  end
end
