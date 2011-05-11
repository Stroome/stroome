class CommentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create]
  before_filter :authorize_delete!, :only => [:delete, :destroy]

  layout :choose_layout

  def choose_layout
    request.xhr? ? nil : 'application'
  end


  ## Project
  def project_list
    project = Project.find(params[:project_id])

    @comments = browse_comments(project, params)

    respond_to do |format|
      format.html { render :template => "comments/list", :layout => nil }
      format.js   { render :template => "comments/list", :layout => nil }
    end
  end

  def project_comments
    project = Project.find(params[:project_id])

    @comments = browse_comments(project, params)
    @comments_path = project_comment_list_path
    @post_comment_path = project_comments_path

    respond_to do |format|
      format.html { render :template => "comments/comments" }
    end
  end

  ## Clip
  def clip_list
    entry = Clip.find(params[:clip_id])

    @comments = browse_comments(entry, params)

    respond_to do |format|
      format.html { render :template => "comments/list", :layout => nil }
      format.js   { render :template => "comments/list", :layout => nil }
    end
  end

  def clip_comments
    entry = Clip.find(params[:clip_id])

    @comments = browse_comments(entry, params)
    @comments_path = clip_comment_list_path
    @post_comment_path = clip_comments_path

    respond_to do |format|
      format.html { render :template => "comments/comments" }
    end
  end

  ## Group
  def group_list
    entry = Group.find(params[:group_id])

    @comments = browse_comments(entry, params)

    respond_to do |format|
      format.html { render :template => "comments/list", :layout => nil }
      format.js   { render :template => "comments/list", :layout => nil }
    end
  end

  def group_comments
    entry = Group.find(params[:group_id])

    @comments = browse_comments(entry, params)
    @comments_path = group_comment_list_path
    @post_comment_path = group_comments_path

    respond_to do |format|
      format.html { render :template => "comments/comments" }
    end
  end



  def browse_comments(entry, params)
    entry.comments.paginate(
      :page => params[:page],
      :per_page => PaginationHelper::COMMENT_BROWSE_PER_PAGE
    )
  end

  # GET /comments
  # GET /comments.xml
  def index
    if params[:project_id]
      @comments = Project.find(params[:project_id]).
          comments.paginate :page => params[:page], :per_page => PaginationHelper::COMMENT_BROWSE_PER_PAGE
    elsif params[:clip_id]
      @comments = Clip.find(params[:clip_id]).
          comments.paginate :page => params[:page], :per_page => PaginationHelper::COMMENT_BROWSE_PER_PAGE
    else
      @comments = Comment.all
    end

    respond_to do |format|
      format.html { render :layout => nil }
      format.xml { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @comment }
    end
  end


  # POST /comments
  # POST /comments.xml
  def create
    #TODO: make sure the user can comment on the clip/project
    @comment = Comment.new(:body => params[:body],
                           :clip_id => params[:clip_id],
                           :project_id => params[:project_id],
                           :group_id => params[:group_id],
                           :user_id => current_user.id,
                           :parent_id => params[:parent_id]
    )

    if @comment.clip_id
      @comments_path = clip_comment_list_path

    elsif @comment.project_id
      @comments_path = project_comment_list_path

    elsif @comment.group_id
      @comments_path = group_comment_list_path

    end

    respond_to do |format|

      if @comment.save
        format.js { }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end


  def delete
    @comment = Comment.find(params[:id])

    render :layout => nil
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.js
      format.xml { head :ok }
    end
  end

  
  protected

  def authorize_delete!
    comment = Comment.find(params[:id])
    current_user_can_delete_comment = user_signed_in? and
        comment.belongs_to_project? and comment.project.project_owner?(current_user)

    unless (admin_signed_in? or current_user_can_delete_comment)
      render :partial => "shared/errors/unauthorized", :status => 401
    end
  end
end
