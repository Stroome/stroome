class GroupsController < ApplicationController
  include ResultsHelper
  
  before_filter :authenticate_user!, :except => [:index, :show, :pending_activity_stream]

  before_filter :topic_ids_default_to_empty_array, :only => [:create, :update]
  before_filter :set_default_pagination_params, :only => [:my_index, :index, :user_index, :recommended]
  before_filter :set_default_results_filter_params, :only => [:index]
  before_filter :set_default_my_groups_browse_params, :only => [:my_index]

  layout :choose_layout

  def request_join
    @group = Group.find(params[:id])

    JoinRequest.request(
        :sender => current_user,
        :receiver => @group.owner,
        :joinable => @group
    ).save

    redirect_to @group, :notice => 'Group Membership Request was successfully sent.'
  end

  def join
    @group = Group.find(params[:id])

    GroupMember.create(
        :user => current_user,
        :group => @group
    )

    redirect_to @group, :notice => 'Group was successfully joined.'
  end

  def unjoin
    @group = Group.find(params[:id])

    group_member = GroupMember.find_by_group_id_and_user_id(params[:id], current_user.id)
    group_member.destroy unless group_member.nil?

    respond_to do |format|
      format.js
      format.html { redirect_to @group, :notice => 'Group was successfully unjoined.' }
    end
  end

  def show
    @group = Group.find(params[:id])
  end
  
  def new
    @group = Group.new

  end

  def create
    @group = Group.new(params[:group])
    @group.owner = current_user

    respond_to do |format|
      if @group.save
        msg_project_created = 'Group was successfully created.'
        @url = my_groups_path

        format.html { redirect_to(@url, :notice => msg_project_created) }
        format.js do
          flash[:notice] = msg_project_created
          render :partial => 'shared/scripts/ajax_redirect',
                 :locals  => { :url => @url }
        end
      else
        format.html { render :action => 'new' }
        format.js do
          content = render_to_string(:action => 'new')
          render :partial => 'shared/ajax_replace_lightbox_content',
                 :locals => { :content => content }
        end
      end
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        @url = group_path(@group)
        flash[:notice] = "Group was successfully updated."

        format.html { redirect_to @url }
        format.js   { render :partial => 'shared/scripts/ajax_redirect',
                             :locals => {:url => @url} }
      else
        format.html { render :action => "edit" }
        format.js do
          content = render_to_string(:action => "edit")
          render :partial => 'shared/ajax_replace_lightbox_content',
                 :locals => { :content => content }
        end
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(my_groups_url) }
    end
  end

  def index
    @search = group_index_search(current_user ? current_user.id : nil, params)

    respond_to do |format|
      format.html { render :layout => 'browse' }
      format.js
    end
  end

  def my_index
    @search = my_group_index_browse(current_user.id, params)

    respond_to do |format|
      format.html
      format.js
    end
  end

  # to show Groups in Profile page
  def user_index
    params[:alpha] = nil
    @search = user_group_index_browse(params[:user_id], params)

    @groups = @search.results
    
    respond_to do |format|
      format.html { render :layout => nil if request.xhr? }
      format.js { render :layout => nil if request.xhr? }
    end
  end

  def recommended
    params[:alpha] = nil
    exclude_group_ids = current_user.group_ids
    @search = recommended_group_browse(
        current_user.interested_in_topic_ids,
        current_user.id, exclude_group_ids, params)

    @groups = @search.results

    respond_to do |format|
      format.html { render :layout => nil if request.xhr? }
      format.js { render :layout => nil if request.xhr? }
    end
  end

  def pending_activity_stream
  end

  def topic_ids_default_to_empty_array
     params[:group][:topic_ids] ||= []
   end

  
  def choose_layout
    request.xhr? ? 'popup' : 'application'
  end

  def set_default_pagination_params
    params[:per_page] ||= PaginationHelper::DEFAULT_BROWSE_PER_PAGE
  end

  def set_default_my_groups_browse_params
   params[:alpha] ||= ResultsHelper::DEFAULT_ALPHABET_OPTION
  end

  def set_default_results_filter_params
    params[:sort] ||= 'recent'
    params[:topic_ids] ||= []
    params[:topic_ids] = params[:topic_ids].collect { |id| id.to_i if id.to_i.to_s == id }
    params[:per_page] ||= PaginationHelper::DEFAULT_BROWSE_PER_PAGE
    params[:alpha] ||= ResultsHelper::DEFAULT_ALPHABET_OPTION
  end


end
