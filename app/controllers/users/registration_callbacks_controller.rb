class Users::RegistrationCallbacksController < ApplicationController

  def check_username
    @user = User.find_by_username(params[:user][:username])

    respond_to do | format|
      format.text { render :text => !@user }
    end
  end

  def check_email

    user = User.find_by_email(params[:user][:email])

    if user_signed_in?
      can_use = ( user.nil? or (current_user.id == user.id) )
    else
      can_use = user.nil?
    end


    respond_to do |format|
      format.text { render :text => can_use }
    end
  end
end
