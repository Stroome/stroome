class ClipsController < ApplicationController
  include ResultsHelper
  
  before_filter :default_results_filter_params, :only => [:index]
  before_filter :default_pagination_params, :only => [:index, :more_from_owner, :more_like_this]

  impressionist :actions => [:show]


  # Shows Clips Browse view.
  def index
    @search = clip_index_search(params)

    respond_to do |format|
      format.html { render :layout => 'browse' }
      format.js
    end
  end
  def deprecated_index
    @clips = Clip.with_topics( params[:topic_ids] )
                 .in_order( params[:sort] )
                 .page( params[:page] )
                 .per( params[:per_page] )

    respond_to do |format|
      format.html { render :layout => 'browse' }
      format.js
    end
  end

  # Shows Clip Detail view.
  def show
    @clip = Clip.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # Shows More From This User view.
  def more_from_owner
    clip = Clip.find(params[:id])

    @search = clip.more_clips_from_owner(params[:page], params[:per_page])

    respond_to do |format|
      format.html { render :layout => nil if request.xhr? }
      format.js   { render :layout => nil }
    end
  end

  # Shows Related Clips view.
  def more_like_this
    clip = Clip.find(params[:id])

    @search = clip.more_clips_like_this(params[:page], params[:per_page])

    respond_to do |format|
      format.html { render :layout => nil if request.xhr? }
      format.js   { render :layout => nil }
    end
  end

  def rate
    @clip = Clip.find(params[:id])
    @clip.rate(params[:stars], current_user, params[:dimension])

    render "shared/_ratings", :layout => nil, :locals => { :rate_object => @clip }
  end
  
  #######
  private

  def default_results_filter_params
    params[:sort] ||= 'recent'
    params[:topic_ids] ||= []
    params[:topic_ids] = params[:topic_ids].collect { |id| id.to_i if id.to_i.to_s == id }
  end

  def default_pagination_params
    params[:per_page] ||= PaginationHelper::DEFAULT_BROWSE_PER_PAGE
  end


end
