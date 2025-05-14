class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create] # Change this to be any actions you want to protect.
  before_action :check_session_devise_omniauth_data, :only => [:new_by_provider, :create_by_provider]
  before_action :configure_permitted_parameters, if: :devise_controller?

	def new
		build_resource({})
		@validatable = devise_mapping.validatable?
		if @validatable
			@minimum_password_length = resource_class.password_length.min
		end
		respond_with resource
	end

  def create
    build_resource(sign_up_params)
    resource.save

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
			clean_up_passwords resource
      set_minimum_password_length
			flash[:error] = "Some error occur."
			respond_with resource
    end
  end

  def new_by_provider
    @resource = User.initialize_from_omniauth(session["devise.omniauth_data"])
    respond_with @resource
  end

  def create_by_provider
    @resource = User.initialize_from_omniauth(session["devise.omniauth_data"])
    @resource.email = params[:user][:email]
    @resource.full_name = params[:user][:full_name]
    @resource.phone = params[:user][:phone]
    @resource.password = Devise.friendly_token[0,20]
    @resource.create_provider_from_omniauth!(session["devise.omniauth_data"])
    if @resource.save
      if @resource.active_for_authentication?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => session["devise.omniauth_data"]["provider"].to_s.titleize
        sign_in(:user, @resource)
        session["devise.omniauth_data"] = nil
        respond_with @resource, location: after_sign_up_path_for(@resource)
      end
    else
      respond_with @resource
    end
  end

protected

  def after_inactive_sign_up_path_for(resource)
    super
    new_user_session_url
  end

  def after_sign_up_path_for(resource)
    users_account_url
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  def check_session_devise_omniauth_data
    redirect_to new_user_registration_path unless session["devise.omniauth_data"]
  end

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :phone])
	end

	def check_captcha
		unless verify_recaptcha
			self.resource = resource_class.new sign_up_params
			resource.validate # Look for any other validation errors besides reCAPTCHA
			set_minimum_password_length
			respond_with_navigational(resource) { render :new }
		end
	end
end
