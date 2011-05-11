class ProjectMembersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :can_managed_by_current_user,
                :only => [
                    :delete, :destroy
                ]
  before_filter :can_accessed_by_current_user,
                :only => [
                  :project_members
                ]
  
  def project_members
    @project = Project.find(params[:project_id])

    @owner = @project.user
    @project_members = @project.project_members

    render :layout => nil if request.xhr?
  end

  def show

  end

  def delete
    @project_member = ProjectMember.find(params[:id])

    render :layout => nil
  end

  def destroy
    @project_member = ProjectMember.find(params[:id])

    @project_member.destroy

    respond_to do |format|
      format.html { render :nothing => true}
      format.js
    end

  end

  def can_managed_by_current_user
    project_member = ProjectMember.find(params[:id])

    unless project_member.project.project_owner?(current_user)
      render :partial => "shared/errors/unauthorized", :status => 401
    end
  end


  def can_accessed_by_current_user
    project = Project.find(params[:project_id])

    unless project.can_accessed_by_user?(current_user)
      render :partial => "shared/errors/unauthorized", :status => 401
    end
  end
end
