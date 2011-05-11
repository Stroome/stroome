class InviteOthersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :can_managed_by_current_user
  
  layout :choose_layout
  
  def new
    if params[:project_id]
      @invite_search_path = invite_to_project_search_path
      @invite_email_path  = invite_to_project_email_path
    elsif params[:group_id]
      @invite_search_path = invite_to_group_search_path
      @invite_email_path  = invite_to_group_email_path
    end
  end

  # Search for users/groups to invite
  def search
    receiver_types = []
    params[:filter] ||= "all"
    
    if params[:project_id]
      @joinable = Project.find(params[:project_id])
      @invite_search_path = invite_to_project_search_path
      @invite_join_path   = invite_join_project_path

      receiver_types = case params[:filter]
        when "user"  then [User]
        when "group" then [Group]
        else [User, Group]
      end

    elsif params[:group_id]
      @joinable = Group.find(params[:group_id])
      @invite_search_path = invite_to_group_search_path
      @invite_join_path   = invite_join_group_path

      receiver_types = [User]
    end

    @search = Sunspot.search( receiver_types ) do
      keywords params[:q]
      order_by :score, :desc
      paginate :page=> params[:page],
               :per_page => PaginationHelper::DEFAULT_BROWSE_PER_PAGE
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def invite_join_group
    @invitation = JoinRequest.invite(
        :receiver_id   => params[:receiver_id],
        :receiver_type => params[:receiver_type],
        :sender        => current_user,
        :joinable_id   => params[:group_id],
        :joinable_type => "Group"
    )

    respond_to do |format|
      if @invitation.save
        format.js { render :template => "invite_others/invited" }
      else
        logger.info @invitation.errors
        format.js { render :js => "alert('invalid request');" }
      end
    end
  end

  # Create invite join request to a project
  def invite_join_project
    @invitation = JoinRequest.invite(
        :receiver_id => params[:receiver_id],
        :receiver_type => params[:receiver_type],
        :sender => current_user,
        :joinable_id => params[:project_id],
        :joinable_type => "Project"
    )

    respond_to do |format|
      if @invitation.save
        format.js { render :template => "invite_others/invited" }
      else
        logger.info @invitation.errors
        format.js { render :js => "alert('invalid request');" }
      end
    end
  end

  def email
    if params[:project_id]
      @email_join_path = email_join_project_path
    else
      @email_join_path = email_join_group_path
    end
  end

  def email_join_project
    @potential_user = PotentialUser.find_by_email(params[:email]) || PotentialUser.new(
        :email   => params[:email],
        :name    => params[:name]
    )
    @potential_user.message = params[:message]

    respond_to do |format|
      if @potential_user.save

        @invitation = JoinRequest.invite_external(
            :receiver => @potential_user,
            :sender => current_user,
            :joinable_id => params[:project_id],
            :joinable_type => "Project"
        )
        @invitation.save

        InviteOthersMailer.invite_join_project(@invitation).deliver

        @notice = "Invitation was sent successfully."
        format.js { render :template => 'invite_others/email_invited' }
      else
        @notice = "Failed to send invitation. Reason: " + @potential_user.errors.values.join(" ")
        format.js { render :template => 'invite_others/email_invited' }
      end

    end


  end

  def email_join_group
    @potential_user = PotentialUser.find_by_email(params[:email]) || PotentialUser.new(
        :email   => params[:email],
        :name    => params[:name]
    )
    @potential_user.message = params[:message]

    respond_to do |format|
      if @potential_user.save

        @invitation = JoinRequest.invite_external(
            :receiver => @potential_user,
            :sender => current_user,
            :joinable_id => params[:group_id],
            :joinable_type => "Group"
        )
        @invitation.save

        InviteOthersMailer.invite_join_group(@invitation).deliver

        @notice = "Invitation was sent successfully."
        format.js { render :template => 'invite_others/email_invited' }
      else
        @notice = "Failed to send invitation. Reason: " + @potential_user.errors.values.join(" ")
        format.js { render :template => 'invite_others/email_invited' }
      end

    end


  end



  def choose_layout
    request.xhr? ? 'popup' : 'application'
  end

  def can_managed_by_current_user
    if params[:project_id]
      project = Project.find(params[:project_id])

      unless project.project_owner?(current_user)
        render :partial => "shared/errors/unauthorized", :status => 401
      end
    elsif params[:group_id]
      group = Group.find(params[:group_id])

      unless group.owner?(current_user)
        render :partial => "shared/errors/unauthorized", :status => 401
      end
    end
  end

end