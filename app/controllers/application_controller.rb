class ApplicationController < ActionController::Base

  protect_from_forgery

	layout :layout_by_resource

	include Locale
  helper :all

  before_action :set_footer_inquiry

  protected

  # The public footer carries a contact form on every page, so it always needs
  # an @inquiry to bind to. Controllers that manage their own inquiry (e.g.
  # InquiriesController#create) overwrite this in their action.
  def set_footer_inquiry
    @inquiry ||= Inquiry.new
  end

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
