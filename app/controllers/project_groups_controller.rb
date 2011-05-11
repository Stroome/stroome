class ProjectGroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :can_accessed_by_current_user,
                :only => [
                  :index
                ]

  def delete
    @project_group = ProjectGroup.find(params[:id])

    render :layout => nil
  end

  def destroy
    @project_group = ProjectGroup.find(params[:id])
    @project_group.destroy

    respond_to do |format|
      format.html { render :nothing =>true }
      format.js
    end
  end

  def index

    @project = Project.find(params[:project_id])
    @project_groups = ProjectGroup.joins(:group).
                        where(:project_id => params[:project_id])

    render :layout => nil if request.xhr?
  end


  def can_accessed_by_current_user
    project = Project.find(params[:project_id])

    unless project.can_accessed_by_user?(current_user)
      render :partial => "shared/errors/unauthorized", :status => 401
    end
  end
end
