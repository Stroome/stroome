class UserFollowing < ActiveRecord::Base
  belongs_to :user
  belongs_to :following, :polymorphic => true

  belongs_to :followed_user, :class_name => "User",
                             :foreign_key=> "following_id"
  belongs_to :followed_group, :class_name => "Group",
                              :foreign_key=> "following_id"


  validates_presence_of :user, :following_id, :following_type

  def self.following_user?(follower, following)
    where(:user_id => follower.id).
    where(:following_type => "User").
    where(:following_id => following.id).size > 0
  end

  def self.following_group?(follower, following)
    where(:user_id => follower.id).
    where(:following_type => "Group").
    where(:following_id => following.id).size > 0
  end
end
