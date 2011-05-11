require 'video_service'
require 'projects_helper'

class ProjectsController < ApplicationController
  include ResultsHelper

  impressionist :actions => [:show]

  before_filter :authenticate_user!,
                :except => [
                    :index, :show,
                    :more_like_this, :more_from_owner
                ]

  before_filter :can_accessed_by_current_user,
                :only => [
                  :show
                ]

  before_filter :can_managed_by_current_user,
                :only => [
                    :manage, :edit, :update, :destroy,
                    :basic_editor, :advanced_editor
                ]


  before_filter :topic_ids_default_to_empty_array, :only => [:create, :update]
  before_filter :load_video_service, :only => [:basic_editor, :advanced_editor, :video_saved]
  before_filter :default_results_filter_params, :only => [:my_index, :index]
  before_filter :default_pagination_params, :only => [:my_index, :index, :more_like_this, :more_from_owner]

  layout :choose_layout

  # Shows Latest Project partial view
  def summary
    respond_to do |format|
      format.html {
        render :layout => nil,
               :partial => "shared/latest_project",
               :locals => {
                   :show_manage_link => params[:show_manage_link] || false,
                   :project => Project.find(params[:id]),
                   :show_player => true
               }
      }
    end
  end

  def comment_widget
    @project = Project.find(params[:id])
    @comment = Comment.new
    
  end

  # Shows My Projects view
  def my_index
    @search = my_project_index_browse(current_user.id, params)

    respond_to do |format|
      format.html
      format.js
    end
  end

  # Show Browse Project view.
  def index
    @search = project_index_search(params, current_user)

    respond_to do |format|
      format.html { render :layout => 'browse' }
      format.js
    end
  end
  
  # Shows More From This User view.
  def more_from_owner
    project = Project.find(params[:id])

    @search = more_projects_from_owner(project, current_user, params)

    respond_to do |format|
      format.html { render :layout => nil if request.xhr? }
      format.js   { render :layout => nil }
    end
  end

  # Shows Related Projects view.
  def more_like_this
    project = Project.find(params[:id])

    @search = more_projects_like_this(project, current_user, params)

    respond_to do |format|
      format.html { render :layout => nil if request.xhr? }
      format.js   { render :layout => nil }
    end
  end

  # Shows Project Detail view.
  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html { render :layout => 'project_detail' }
    end
  end

  # Shows Manage Project view.
  def manage
    @project = Project.find(params[:id])

    begin
      _update_info_from_video_service(@project) if @project.video_updated_recently?
    rescue
      logger.info "[manage project] failed when contacting remote video service."
    end

    respond_to do |format|
      format.html { render :layout => 'project_detail' }
    end
  end

  # Shows Create New Project view.
  def new
    @project = Project.new

    unless params[:remix].blank?
      begin
        remixed_from = Project.find(params[:remix])
        @project = remixed_from.clone_for_remix
        @project.title = "" 
      rescue => ignored
      end
    end

    unless params[:with_clip].blank?
      begin
        clip_to_append = Clip.find(params[:with_clip])
        @project.with_clip_video_id = clip_to_append.video_id
      rescue => ignored
      end
    end
  end

  # Shows Edit a Project view.
  def edit
    @project = Project.find(params[:id])
  end

  # Creates new project with current login user as project owner.
  # Redirects to Manage Project view when successfully created.
  def create
    @project = Project.new(params[:project])
    @project.user = current_user

    msg_project_created = 'Project was successfully created.'

    respond_to do |format|
      if @project.save
        query_params = {:launch_editor=>true}  #always auto-launch editor #@project.remixed_from_id.blank? ? {} : {:launch_editor=>true}

        @url = manage_project_path(@project, query_params)

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

  # Updates existing project info.
  # Redirects to Manage Project view when successfully updated.
  def update
    @project = Project.find(params[:id])


    respond_to do |format|
      if @project.update_attributes(params[:project])

        @url = manage_project_path(@project)
        flash[:notice] = 'Project was successfully updated.'

        format.html { redirect_to @url }
        format.js   { render :partial => 'shared/scripts/ajax_redirect', :locals => {:url => @url} }
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

  # Delete existing project.
  # Redirects to My Projects view after project deleted.
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(my_projects_url) }
    end
  end

  # Shows Basic Editor view.
  def basic_editor
    _editor
  end

  # Shows Advanced Editor view.
  def advanced_editor
    _editor
  end

  # Basic & Advanced Editors use same controller setup, but different views.
  def _editor
    @project = Project.find(params[:id])

    username = current_user.username

    #setup_editor_uiconf(@project)  # for custom search, halt implementation now.

    @flash_vars = video_editor_flashvars(@project.video_id, username)
    begin
      @flash_vars[:ks] = @video_service.new_edit_session(username)
    rescue => ex
      @message = 'Failed to create kaltura edit session.'
      logger.error "[kaltura] #{ @message } Reason:"
      logger.error ex.inspect
      render 'shared/error_message' and return
    end

    render :layout => false if request.xhr?
  end

  # Updates project video-related info and clips info.
  # Redirects to Manage Project view.
  def video_saved

    project = Project.find(params[:id])
    project.touch(:video_updated_at) # touch timestamp, to signal ProjectsController#manage() to contact video service

    # NOTE: moved the task to ProjectsController#manage()
    # -- see how it goes
    #
    # _update_info_from_video_service(project)


    respond_to do |format|
      format.html { redirect_to manage_project_path(project) }
    end
  end

  def rate
    @project = Project.find(params[:id])
    @project.rate(params[:stars], current_user, params[:dimension])

    render "shared/_ratings", :layout => nil, :locals => { :rate_object => @project }
  end


  #######
  private

  def _update_info_from_video_service(project)
    service = SyncWithVideoService.new(KalturaVideoService.new(C.kaltura))
    service.sync_project_video_n_clips_info(project, project.logger)
  end

  def can_managed_by_current_user
    project = Project.find(params[:id])

    unless project.project_owner?(current_user)
      render :partial => "shared/errors/unauthorized", :status => 401
    end
  end

  def can_accessed_by_current_user
    project = Project.find(params[:id])

    unless project.can_accessed_by_user?(current_user)
      render :partial => "shared/errors/unauthorized", :status => 401
    end
  end

  def setup_editor_uiconf(project)
    that = self
    s = SyncWithVideoService.new(KalturaVideoService.new(C.kaltura),
            lambda {|project_id, user_id| that.clip_bin_search_url(:project_id => project_id, :user_id => user_id) })

    case project.editor_type
      when Project::EDITOR_TYPE_BASIC then s.update_project_kse_uiconf(project)
      when Project::EDITOR_TYPE_ADVANCED then s.update_project_kae_uiconf(project)
    end

    project.save if project.changed?
  end

  def default_results_filter_params
    params[:sort] ||= 'recent'
    params[:topic_ids] ||= []
    params[:topic_ids] = params[:topic_ids].collect { |id| id.to_i if id.to_i.to_s == id }
  end

  def default_pagination_params
    params[:per_page] ||= PaginationHelper::DEFAULT_BROWSE_PER_PAGE
  end

  def topic_ids_default_to_empty_array
    params[:project][:topic_ids] ||= []
  end

  def load_video_service
    @video_service = VideoService.new(C.kaltura)
  end

  def choose_layout
    request.xhr? ? 'popup' : 'application'
  end

  def video_editor_flashvars(video_id, username)
    {
      partnerId: C.kaltura.partner_id,
      subpId: C.kaltura.subpartner_id,
      uid: username,
      ks: nil,
      kshowId: -1,
      entryId: video_id
    }
  end

  # TODO extract class, extract method
  def update_project_after_editor_saved(project)
    begin
      session = @video_service.new_admin_session(current_user.username)
      client = @video_service.new_client(session)

      # update duration
      entry = @video_service.get_video_mix(project.video_id, client)
      project.duration = entry.duration
      project.thumbnail_url = entry.thumbnail_url

      # update clips used in project
      media_entries = @video_service.get_clips_used_in_video_mix(project.video_id, client) or []
      media_entries = media_entries.select { |entry| entry.media_type == Kaltura::Constants::Media::Type::VIDEO }
      project.clips.clear # delete all

      media_entries.each do |media_entry|
        clip = Clip.find_by_video_id(media_entry.id) || Clip.new
        clip.title = media_entry.name
        clip.description = media_entry.description
        #TODO clip.topics = mediaEntry.categories
          clip.topics = project.topics # TODO replace once Kaltura Category Sync done
        clip.tags     = media_entry.tags
        clip.duration = media_entry.duration
        clip.video_id = media_entry.id
        clip.thumbnail_url = media_entry.thumbnail_url
        clip.user = current_user

        clip.save

        project.clips << clip if project.clips.exclude?(clip)
      end
      project.save

    rescue Exception => ex
      logger.error "[kalture] Error when update project after editor saved. Reason:"
      logger.error ex.inspect
    end
  end
end
