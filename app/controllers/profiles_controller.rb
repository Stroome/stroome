class ProfilesController < ApplicationController
  include ResultsHelper

  before_filter :authenticate_user!
  before_filter :default_results_filter_params, :only => [:index]

  # Shows Browse Profile view.
  def index
    @search = profile_index_search(params)
    
    respond_to do |format|
      format.html { render :layout => 'browse' }
      format.js
    end
  end

  def deprecated_index
    @users = User.with_topics( params[:topic_ids] )
                 .in_order( params[:sort] )
                 .page( params[:page] )
                 .per( params[:per_page] )

    respond_to do |format|
      format.html { render :layout => 'browse' }
      format.js
    end
  end

  # Shows Profile Detail view.
  def show
    @user = User.find(params[:id])
    @user_latest_projects = user_latest_projects(@user, current_user)
    impressionist(@user)
  end

  #######
  private

  def default_results_filter_params
    params[:sort] ||= 'recent'
    params[:topic_ids] ||= []
    params[:topic_ids] = params[:topic_ids].collect { |id| id.to_i if id.to_i.to_s == id }
    params[:per_page] ||= PaginationHelper::DEFAULT_BROWSE_PER_PAGE
    params[:alpha] ||= ResultsHelper::DEFAULT_ALPHABET_OPTION
  end

end
