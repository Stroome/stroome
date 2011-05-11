class ProjectGroup < ActiveRecord::Base
  belongs_to :project
  belongs_to :group

  after_create :reindex_project
  after_destroy :reindex_project

  after_create :update_activity_stream


  private
  def reindex_project
    self.project.index
  end

  def update_activity_stream
    Activity.joined_by_project(group, project) if project.is_public?
  end
end
