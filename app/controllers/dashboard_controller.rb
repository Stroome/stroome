class DashboardController < ApplicationController
   include ResultsHelper
   
  before_filter :authenticate_user!

  def show
    # TODO move latest_projects to Project domain
    @projects = latest_projects(current_user, 75)
  end
end
