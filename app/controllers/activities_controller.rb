class ActivitiesController < ApplicationController

  before_filter :default_pagination_params
  before_filter :default_filter_params

  layout :choose_layout

  def choose_layout
    request.xhr? ? nil : 'application'
  end

  def group_stream
    group = Group.find(params[:group_id])

    @stream = Activity.recent_group_stream(group, params[:filter]).
        paginate(
          :page => params[:page],
          :per_page => params[:per_page]
        )
    @filter_options = Activity::GROUP_STREAM_FILTER_OPTIONS
    @filter_path    = group_activities_path(group)

    respond_to do |format|
      format.html { render :template => "activities/stream" }
      format.js   { render :template => "activities/stream" }
    end
  end

  def user_stream
    user = User.find(params[:user_id])

    @stream = Activity.recent_user_stream(user, params[:filter]).
        paginate(
          :page => params[:page],
          :per_page => params[:per_page]
        )
    @filter_options = Activity::USER_STREAM_FILTER_OPTIONS
    @filter_path    = user_activities_path(user)
    
    respond_to do |format|
      format.html { render :template => "activities/stream" }
      format.js   { render :template => "activities/stream" }
    end

  end

  def my_follow_stream
    @stream = Activity.recent_follow_stream(current_user, params[:filter]).
        paginate(
          :page => params[:page],
          :per_page => params[:per_page]
        )
    @filter_options = Activity::FOLLOW_STREAM_FILTER_OPTIONS
    @filter_path    = my_follow_stream_path

    respond_to do |format|
      format.html { render :template => "activities/stream" }
      format.js   { render :template => "activities/stream" }
    end

  end

  def default_pagination_params
    params[:per_page] ||= PaginationHelper::DEFAULT_BROWSE_PER_PAGE
  end

  def default_filter_params
    params[:filter] ||= "all"
  end
end
