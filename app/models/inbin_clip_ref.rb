class InbinClipRef < ActiveRecord::Base
  belongs_to :inbin_clip_owner, :polymorphic => true
  belongs_to :clip

  validates_presence_of :inbin_clip_owner_id, :inbin_clip_owner_type, :clip_id

  # available for :through association readonly purpose
  belongs_to :project, :class_name => "Project",
                       :foreign_key => "inbin_clip_owner_id"

  belongs_to :user, :class_name => "User",
                    :foreign_key => "inbin_clip_owner_id"

  
  def used_in_project?(project_id)
    project = Project.find(project_id)

    project.clips.include? self.clip
  end

  def in_project_clip_bin?
    self.inbin_clip_owner_type == "Project"
  end

  def in_user_clip_bin?
    self.inbin_clip_owner_type == "User"
  end

  def can_managed_by_user?(user)
    return false if user.nil?

    if in_project_clip_bin?
      self.project.user_id == user.id
    elsif in_user_clip_bin?
      self.user.id == user.id
    else
      false
    end
  end

end