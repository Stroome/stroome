class Users::RegistrationsController  < Devise::RegistrationsController
  before_filter :fix_nil_array_param, :only => [:create, :update]
  before_filter :cleanup_fb_session, :only => [:new]

  def after_update_path_for(resource)
    edit_user_registration_path
  end


  # POST /resource
  def create
    build_resource

    if resource.save

      if ( params[:invite] )
        request = JoinRequest.find_by_external_id_and_status(params[:invite], JoinRequest::STATUS::PENDING)
        if (request)
          request.accepted_by_user(resource)
        end
      end

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_in_and_redirect(resource_name, resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s
        expire_session_data_after_sign_in!
        redirect_to after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end


  #######
  private

  def fix_nil_array_param
    params[:user][:interested_in_topic_ids] ||=[]
  end

  def cleanup_fb_session
    if (not user_signed_in? and not params[:from] == "fb")
       session["devise.facebook_data"] = nil
    end
  end
end