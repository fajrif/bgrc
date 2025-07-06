class ApplicationController < ActionController::Base

  protect_from_forgery

	layout :layout_by_resource

	include Locale
  helper :all

  protected

  def layout_by_resource
		if devise_controller?
			if controller_path.include? "admin"
				"login"
			else
				"login_user"
			end
    else
      "application"
    end
  end

end
