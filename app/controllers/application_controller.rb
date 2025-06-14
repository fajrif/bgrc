class ApplicationController < ActionController::Base

  protect_from_forgery

	layout :layout_by_resource

	include Locale
  helper :all

  protected

  def layout_by_resource
		if controller_path.include? "admin"
			if devise_controller?
				"login"
			else
				"admin"
			end
    else
      "application"
    end
  end

end
