class InbinClipRefsController < ApplicationController
  layout Proc.new {|controller| controller.request.xhr? ? 'popup' : 'application' }

  before_filter :authenticate_user!
  before_filter :can_managed_by_current_user, :only => [:use, :delete, :destroy]
  before_filter :can_browsed_by_current_user, :only => [:project_clip_bin, :user_clip_bin]

  CURRENT_USER_CLIP_BIN = "current_user_clip_bin"

  def can_managed_by_current_user
    clip_bin = InbinClipRef.find(params[:id])

    unless clip_bin.can_managed_by_user? current_user
      render :partial => "shared/errors/unauthorized", :status => 401
    end
  end

  def can_browsed_by_current_user
    can_browse = false
    
    if user_id = params[:user_id]
      can_browse = user_id == current_user.id.to_s
    elsif project_id = params[:project_id]
      p = Project.find(project_id)
      can_browse = p.project_owner?(current_user)
    end

    unless can_browse
      return render :partial => "shared/errors/unauthorized", :status => 401
    end
  end

  def use
    @project = Project.find(params[:add_to_project_id])

    unless @project.project_owner?(current_user)
      return render :partial => "shared/errors/unauthorized", :status => 401
    end

    @inbin_clip = InbinClipRef.includes(:clip).find(params[:id])
    clip_video_id = @inbin_clip.clip.video_id

    service = SyncWithVideoService.new(KalturaVideoService.new(C.kaltura))
    service.append_clip(@project, clip_video_id)

    respond_to do |format|
      format.js
    end
  end

  def delete
    @inbin_clip = InbinClipRef.includes(:clip).find(params[:id])
  end

  def destroy
    @inbin_clip = InbinClipRef.find(params[:id])
    @inbin_clip.destroy

    respond_to do |format|
      format.js
    end
  end


  # Shows Project Clip Bin view.
  def project_clip_bin
    clip_bin("Project", params[:project_id])
  end

  def user_clip_bin
    clip_bin("User", params[:user_id])
  end

  def clip_bin(class_name, id)
    @results = InbinClipRef.includes(:clip).
        where("inbin_clip_owner_type = '#{ class_name }' AND inbin_clip_owner_id = ?", id).
        paginate(:page => params[:page], :per_page => PaginationHelper::DEFAULT_BROWSE_PER_PAGE)

    respond_to do |format|
      format.html { render :layout => nil if request.xhr? }
      format.js { render :layout => nil if request.xhr? }
    end
  end

  
  def new
    @clip = Clip.find(params[:clip_id])
    @inbin_clip = InbinClipRef.new(:clip => @clip)

    project_options = Project.where("user_id = ?", current_user.id ).
                              order("updated_at DESC").
                              collect { |project| ["- #{ project.title }", "Project:#{ project.id }"] }

    @project_grouped_options = [
        [ "A Project Clip Bin", project_options ]
    ]

    respond_to do |format|
      format.html
    end
  end

  def create
    @inbin_clip = InbinClipRef.new
    @inbin_clip.clip_id = params[:clip_id]

    if params[:add_to_bin] == "current_user_clip_bin"
      owner_info = ["User", current_user.id]
    else
      owner_info = params[:add_to_bin].split(":")
    end

    @inbin_clip.inbin_clip_owner_type = owner_info[0]
    @inbin_clip.inbin_clip_owner_id = owner_info[1]

    logger.info "clip bin ref: #{ @inbin_clip.inspect }"
    
    if inbin_clip_exists? @inbin_clip
      @notice = "This clip is already in the clip bin."
    elsif @inbin_clip.save
      @notice = "This clip is added successfully."
    else
      @notice = "Error when adding this clip to clip bin."
    end

    @clip = Clip.find(params[:clip_id])
    project_options = Project.where("user_id = ?", current_user.id ).
                         order("updated_at DESC").
                         collect { |project| ["- #{ project.title }", "Project:#{ project.id }"] }

    @project_grouped_options = [
       [ "A Project Clip Bin", project_options ]
    ]


    respond_to do |format|
      format.html
      format.js do
        @content = render_to_string(:action => "new")
        logger.info "test -> "
        logger.info @content
        render :partial => "shared/ajax_replace_lightbox_content",
               :locals => { :content => @content }
      end
    end
  end

  ####
  protected

  def inbin_clip_exists?(inbin_clip)
    not InbinClipRef.where("clip_id = ? AND inbin_clip_owner_id = ? AND inbin_clip_owner_type = ?",
                        inbin_clip.clip_id,
                        inbin_clip.inbin_clip_owner_id,
                        inbin_clip.inbin_clip_owner_type).empty?
  end

end
