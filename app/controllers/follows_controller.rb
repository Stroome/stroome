class FollowsController < ApplicationController

  before_filter :authenticate_user!

  def follow_user
    @user = User.find(params[:user_id])
    @partial_view = "follows/unfollow_user.html.erb"

    @following = @user

    UserFollowing.create(
        :user => current_user,
        :following => @user
    ) unless UserFollowing.following_user? current_user, @user
    

    respond_to do |format|
      format.js { render :template => "follows/replace_follow_button.js.erb" }
    end
  end

  def unfollow_user

    @user = User.find(params[:user_id])
    @partial_view = "follows/follow_user.html.erb"

    @following = @user

    results = UserFollowing.
        where(:user_id => current_user.id).
        where(:following_type => "User").
        where(:following_id => @user.id)

    results.each do |entry|
      entry.destroy
    end

    respond_to do |format|
      format.js { render :template => "follows/replace_follow_button.js.erb" }
    end

  end

  def follow_group
    @group = Group.find(params[:group_id])
    @partial_view = "follows/unfollow_group.html.erb"

    @following = @group

    UserFollowing.create(
        :user => current_user,
        :following => @group
    ) unless UserFollowing.following_group? current_user, @group

    respond_to do |format|
      format.js { render :template => "follows/replace_follow_button.js.erb" }
    end
  end

  def unfollow_group
    @group = Group.find(params[:group_id])
    @partial_view = "follows/follow_group.html.erb"

    @following = @group

    results = UserFollowing.
        where(:user_id => current_user.id).
        where(:following_type => "Group").
        where(:following_id => @group.id)

    results.each do |entry|
      entry.destroy
    end

    respond_to do |format|
      format.js { render :template => "follows/replace_follow_button.js.erb" }
    end
  end

end
