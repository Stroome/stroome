class ProjectMember < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  after_create :reindex_project
  after_destroy :reindex_project

  private
  def reindex_project
    self.project.index
  end
end
