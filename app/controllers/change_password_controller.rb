class ChangePasswordController < ApplicationController
  before_filter :authenticate_user!

  layout :choose_layout

  # Shows Change Password view.
  def edit
    @user = current_user
  end

  # Updates password. Re-login required after password changed successfully.
  def update
    @user = current_user

    respond_to do |format|
      if @user.change_current_password(params[:user])

        # HACK: to relogin user after password changed
        #
        sign_in(@user, :bypass => true) if @user == current_user

        @url = edit_user_registration_url
        flash[:notice] = "Password was changed successfully."

        format.html { redirect_to edit_user_registration_path }
        format.js   {
          render :partial => 'shared/scripts/ajax_redirect',
                 :locals  => { :url => @url }
        }

      else
        format.html { render :edit }
        format.js do
          content = render_to_string :edit
          render :partial => 'shared/ajax_replace_lightbox_content',
                 :locals => { :content => content }
        end
      end
    end
  end

  ####
  private

  def choose_layout
    request.xhr? ? 'popup' : 'application'
  end
end
