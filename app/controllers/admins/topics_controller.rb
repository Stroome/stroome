class Admins::TopicsController < ApplicationController
  before_filter :authenticate_admin!
  layout "admin"
  respond_to :html

  def index
    @topics = Topic.paginate(:page => params[:page])

    respond_with @topics
  end

  def show
    @topic = Topic.find(params[:id])

    respond_with @topic
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to(admins_topic_url(@topic), :notice => "Category was successfully created.") }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @topic = Topic.find(params[:id])

    respond_with @topic
  end

  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        format.html { redirect_to(admins_topic_url(@topic), :notice => "Category was successfully updated.")}
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_with @topic, :location => admins_topics_url
  end
end
