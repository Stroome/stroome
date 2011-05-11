class Admins::DashboardController < ApplicationController
  before_filter :authenticate_admin!
  layout "admin"
  
  def show
  end
end
