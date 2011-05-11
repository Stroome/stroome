class Users::SessionsController < Devise::SessionsController
  layout Proc.new { |controller| controller.request.xhr? ? 'popup' : 'application' }, :only => [:new, :create]

  skip_filter :require_no_authentication
  prepend_before_filter :require_no_authentication_with_ajax_support, :only => [:new, :create]
  
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_with( resource ) do |format|

      format.html {
        redirect_to user_root_path
      }
      format.js {
        render :partial => 'shared/scripts/ajax_redirect',
               :locals => {
                   :url => user_root_path
               }
      }
    end
  end

  # hack: when logged in user clicks Sign In lightbox link, redirects user properly to dashboard page.
  def require_no_authentication_with_ajax_support
    if warden.authenticated?(resource_name)
      resource = warden.user(resource_name)
      respond_with( resource ) do |format|
        format.html {
          if request.xhr?
            return render  :partial => 'shared/scripts/ajax_redirect',
                           :locals  => {
                               :url => user_root_path
                           }
          else
            return redirect_to user_root_path
          end
        }
      end

    end
  end
end