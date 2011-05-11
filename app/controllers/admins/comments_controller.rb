class Admins::CommentsController < ApplicationController
  before_filter :authenticate_admin!
  layout "admin"
  respond_to :html

  def index
    @comments = Comment.
        order("created_at DESC").
        paginate(:page => params[:page])

    respond_with @comments
  end

  def show
    @comment = Comment.find(params[:id])

    respond_with @comment
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_with @comment, :location => admins_comments_url
  end
end
