class UserNotificationsController < ApplicationController
  before_filter :authenticate_user!

  layout :choose_layout

  def index
    @notifications = UserNotification.
                        where("user_id = ?", current_user.id).
                        where("status = ?", UserNotification::STATUS::ACTIVE ).
                        order("created_at DESC").
                        paginate(
                          :page => params[:page],
                          :per_page => PaginationHelper::DEFAULT_BROWSE_PER_PAGE )

    respond_to do |format|
      format.html
      format.js
    end

  end

  def update

    @notification = UserNotification.find(params[:id])

    @notification.inactive!
    @notification.save

    case params[:reply]
      when "yes" then @notification.actionable.yes
      when "no"  then @notification.actionable.no
    end

    respond_to do |format|
      format.js
    end

  end

  ###
  protected

  def choose_layout
    request.xhr? ? nil : "application"
  end
end
