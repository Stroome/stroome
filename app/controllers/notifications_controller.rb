class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  
  layout Proc.new { |controller| controller.request.xhr? ? nil : "application" }

  def my_index
    @notifications = Notification.
        where("user_id = ?", current_user.id ).
        order("created_at DESC").
        paginate(:page => params[:page], :per_page => PaginationHelper::DEFAULT_BROWSE_PER_PAGE)

    respond_to do |format|
      format.html
      format.js
    end
  end


  def update
    @notification = Notification.find(params[:id])

    @notification.status = params[:status]

    respond_to do |format|
      if @notification.save
        @notification.notify_status_updated

        format.js
      end

    end
   end
end
