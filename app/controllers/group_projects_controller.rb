class GroupProjectsController < ApplicationController

  before_filter :authenticate_user!, :only => [:destroy, :reply]
  before_filter :can_accessed_by_current_user!

  before_filter :default_pagination_params

  def reply
    request = JoinRequest.find(params[:join_request])

    if request.pending?

      case params[:reply]
        when "yes" then request.yes
        when "no"  then request.no
      end

    end

  end

  def destroy
    @project_group = ProjectGroup.find(params[:id])
    @project_group.destroy

    params[:group_id] = @project_group.group.id
    
    render :action => 'reply'
    
  end
  
  def index

    params[:filter] ||= "all"

    group = Group.find(params[:group_id])

    @results = browse_group_projects( group, current_user, params[:filter], params[:page], params[:per_page] )

    @can_manage = group.owner?(current_user)

    render :layout => nil if request.xhr?
  end

  def browse_group_projects(group, current_user, filter, page, per_page)

    existing_projects = []
    new_projects = []

    existing_projects = ProjectGroup.where(:group_id => params[:group_id]) if ["all", "existing"].include? filter
    new_projects = JoinRequest.pending_projects_for_group_approval(params[:group_id]) if ["all", "new"].include? filter

    if not group.owner?(current_user)

      existing_projects = filter_by_user_access_rights( existing_projects , current_user )
      new_projects      = []

    end

    all_results = existing_projects + new_projects

    all_results.paginate(:page => page, :per_page => per_page)
  end

  def can_accessed_by_current_user!
    group = Group.find(params[:group_id])

    if group.limited_access_to_user? current_user
      render :partial => "shared/errors/unauthorized", :status => 401
    end
  end

  def filter_by_user_access_rights( project_groups, user )
    project_groups.select {|pg| pg.project.can_accessed_by_user?(user) }
  end

  def default_pagination_params
    params[:per_page] ||= 3
    params[:page] ||= 1
  end
end
