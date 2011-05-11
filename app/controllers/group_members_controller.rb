class GroupMembersController < ApplicationController
  layout :choose_layout
  before_filter :authenticate_user!
  before_filter :can_managed_by_current_user, :only => [:delete, :destroy]

  def can_managed_by_current_user
    group_member = GroupMember.find(params[:id])

    unless group_member.group.owner? current_user
      render :partial => 'shared/errors/unauthorized', :status => 401
    end
  end

  def index
    @group_members = GroupMember.
        where(:group_id => params[:group_id]).
        paginate(
          :page => params[:page],
          :per_page => PaginationHelper::DEFAULT_BROWSE_PER_PAGE
        )

    respond_to do |format|
      format.html
      format.js
    end
  end

  def delete
    @group_member = GroupMember.find(params[:id])

    render :layout => nil
  end

  def destroy
    @group_member = GroupMember.find(params[:id])
    @group_member.destroy

    respond_to do |format|
      format.html { render :nothing =>true }
      format.js
    end
  end


  ###
  protected

  def choose_layout
    request.xhr? ? nil : "application"
  end
end
