# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show follow unfollow following followers]
    before_action :set_target_user, only: %i[follow unfollow]

    # GET /v1/users/:id
    def show
      render_json(UserSerializer, @user, { params: { detailed: true } })
    end

    # POST /v1/users/:id/follow
    def follow
      follow_relationship = Users::FollowService.call(@user, @target_user)
      render_json(FollowSuccessSerializer, {
                    follower: @user,
                    followed_user: @target_user,
                    follow_relationship: follow_relationship
                  }, { status: :created })
    end

    # DELETE /v1/users/:id/unfollow
    def unfollow
      Users::UnfollowService.call(@user, @target_user)
      render_json(UnfollowSuccessSerializer, {
                    follower: @user,
                    unfollowed_user: @target_user
                  })
    end

    # GET /v1/users/:id/following
    def following
      following_users = paginate_collection(@user.following)
      render_json(UserSerializer, following_users, {
                    meta: {
                      user_id: @user.id,
                      user_name: @user.name,
                      following_count: @user.following.count
                    }
                  })
    end

    # GET /v1/users/:id/followers
    def followers
      follower_users = paginate_collection(@user.followers)
      render_json(UserSerializer, follower_users, {
                    meta: {
                      user_id: @user.id,
                      user_name: @user.name,
                      followers_count: @user.followers.count
                    }
                  })
    end

    # GET /v1/users
    def index
      users = paginate_collection(User.all)
      render_json(UserSerializer, users, { params: { include_counts: true } })
    end

    # POST /v1/users
    def create
      @user = User.new(user_params)

      if @user.save
        render_json(UserSerializer, @user, { status: :created })
      else
        render_json_error_validation(@user)
      end
    end

    private

    def set_user
      @user = User.find(params[:id] || params[:user_id])
    end

    def set_target_user
      @target_user = User.find(params[:target_user_id])
    end

    def user_params
      params.require(:user).permit(:name)
    end
  end
end
