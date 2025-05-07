class Admins::BaseController < ActionController::Base
  layout "admin"

	include Locale

  protect_from_forgery

  # Devise filter authenticate admin
  before_action :authenticate_admin!
	before_action :check_authorization!

	include Pundit::Authorization

	rescue_from Pundit::NotAuthorizedError, with: :admin_not_authorized

  # include all helpers, all the time
  helper :all

	def pundit_user
		current_admin
	end

	private

  def admin_not_authorized
		flash[:alert] = t('admins.unautorized')
    redirect_back(fallback_location: admins_root_path)
  end

	def check_authorization!
		unless GENERAL_CLASS_RESOURCES.include? controller_name
			if INVESTOR_CLASS_RESOURCES.include? controller_name
				authorize :investor
			elsif DEVELOPER_CLASS_RESOURCES.include? controller_name
				authorize :developer
			elsif ADMIN_CLASS_RESOURCES.include? controller_name
				authorize :admin
			end
		end
	end

end
