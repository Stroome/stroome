class Admins::UsersController < ApplicationController
  before_filter :authenticate_admin!
  layout "admin"
  respond_to :html

  def index
    @users = User.paginate(:page => params[:page])

    respond_with @users
  end

  def show
    @user = User.find(params[:id])

    respond_with @user
  end

  def edit
    @user = User.find(params[:id])

    respond_with @user
  end

  def update
    @user = User.find(params[:id])
    @user.should_confirm_email = false
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(admins_user_url(@user), :notice => "User was successfully updated.")}
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def reset_password
    @user = User.find(params[:id])

    email_in_hashmap = { :email => @user.email }
    User.send_reset_password_instructions(email_in_hashmap)

    respond_to do |format|
      if @user.errors.empty?
        format.html { redirect_to(edit_admins_user_url(@user),
                        :notice => "Password reset instruction has been sent to '#{ @user.email }'.") }
      else
        format.html { redirect_to(edit_admins_user_url(@user),
                        :notice => "Failed to reset password. Reason: #{ @user.full_messages.join(", ") }")}
      end
    end
  end
end
