class UserSerializer < ApplicationSerializer
  attributes :id, :name, :created_at

  attribute :following_count, if: Proc.new { |_record, params|
    params && (params[:detailed] || params[:include_counts])
  } do |object|
    object.following.count
  end

  attribute :followers_count, if: Proc.new { |_record, params|
    params && (params[:detailed] || params[:include_counts])
  } do |object|
    object.followers.count
  end
end
