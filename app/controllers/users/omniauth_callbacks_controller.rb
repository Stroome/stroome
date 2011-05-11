class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)

    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      flash[:notice] = "Go ahead and create your new account, it will be connected with your Facebook account. We have already filled in some of the information for you!"
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url(:from => "fb")
    end
  end

  def sign_in_and_redirect(resource_or_scope, *args)
    options  = args.extract_options!
    scope    = Devise::Mapping.find_scope!(resource_or_scope)
    resource = args.last || resource_or_scope
    sign_in(scope, resource, options)
    redirect_to user_root_path
  end

end