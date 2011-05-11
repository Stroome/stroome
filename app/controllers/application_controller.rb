class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource_or_scope)

    if resource_or_scope.is_a?(Admin)
      admins_root_url
    elsif resource_or_scope.is_a?(User)
      user_root_url
    else
      url = super
    end

  end

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope.is_a?(Admin) or resource_or_scope == :admin
      admins_root_url
    else
      url = super
    end
  end
 
end
