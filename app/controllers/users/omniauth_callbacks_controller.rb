class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :check_authenticated_user

  def facebook
    provider_callbacks(:facebook)
  end

  def google_oauth2
    provider_callbacks(:google_oauth2)
  end

private

  def provider_callbacks(provider)
    request.env["omniauth.auth"].delete("extra")
    session["devise.omniauth_data"] = request.env["omniauth.auth"]

    # find user from provider
    user = User.find_for_omniauth(session["devise.omniauth_data"])
    if user and user.persisted?
      sign_in_with_omniauth(user, provider)
    else
      if user and user.valid?
        # create user and provider
        user.create_provider_from_omniauth!(session["devise.omniauth_data"])
        sign_in_with_omniauth(user, provider)
      else
        # only fallback to new_user_registration_by_provider page if required fields was empty
        redirect_to new_user_registration_by_provider_url, :notice => "Some fields are required"
      end
    end
  rescue Exception => e
    redirect_to new_user_session_path, :alert => e.message
  end

  def sign_in_with_omniauth(user, provider)
    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => provider.to_s.titleize
    sign_in(user, :bypass => true)
    booking_return = session[:booking_return_url]
    session["devise.omniauth_data"] = nil
    if booking_return.present?
      session.delete(:booking_return_url)
      redirect_to booking_return
    else
      redirect_to users_root_url(:protocol => 'http')
    end
  end

  # it will assign the provider data with the current_user
  def check_authenticated_user
    if user_signed_in?
      @provider = Provider.new(provider: request.env["omniauth.auth"]["provider"], uid: request.env["omniauth.auth"]["uid"], access_token: request.env["omniauth.auth"]["credentials"]["token"], access_secret: request.env["omniauth.auth"]["credentials"]["secret"])
      current_user.providers << @provider
      if current_user.save!
        redirect_to edit_users_preference_path, :notice => "Successfully add new provider."
      else
        raise 'Unable to add new provider.'
      end
    end
  rescue Exception => e
    redirect_to edit_user_account_path, :alert => e.message
  end

end
