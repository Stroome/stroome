class Admins::RegistrationsController  < Devise::RegistrationsController
  before_filter :forbid_sign_up_if_admin_exists, :only => [:new]
  layout "admin"

  private
  def forbid_sign_up_if_admin_exists
    redirect_to new_admin_session_url if not Admin.first.nil?
  end


end