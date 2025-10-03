class FollowSuccessSerializer < ApplicationSerializer
  set_id { |_| 'follow_success' }
  set_type :follow_success
  attribute :message do |object|
    "Successfully followed #{object[:followed_user].name}"
  end
  attribute :follower do |object|
    {
      id: object[:follower].id,
      name: object[:follower].name
    }
  end

  attribute :followed_user do |object|
    {
      id: object[:followed_user].id,
      name: object[:followed_user].name
    }
  end

  attribute :following_count do |object|
    object[:follower].following.count
  end

  attribute :created_at do |object|
    object[:follow_relationship].created_at
  end
end
