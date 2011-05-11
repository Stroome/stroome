class GroupMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates_presence_of :user_id, :group_id
  validates_uniqueness_of :user_id, :scope => :group_id

  after_create :reindex_group
  after_destroy :reindex_group

  after_create :update_activity_stream_on_joined
  after_destroy :update_activity_stream_on_unjoined

  protected
  def reindex_group
    self.group.index
  end

  def update_activity_stream_on_joined
    Activity.joined(user, group)
  end

  def update_activity_stream_on_unjoined
    Activity.unjoined(user, group)
  end
end
