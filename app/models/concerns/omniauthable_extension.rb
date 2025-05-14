module OmniauthableExtension
  extend ActiveSupport::Concern

  module ClassMethods
    # these both Class methods are needed for Authenticate using OmniAuth 1.0
    def find_for_omniauth(request_env)
			re = JSON.parse(request_env.to_json, object_class: OpenStruct)
      user = nil
      provider = Provider.where(provider: re.provider, uid: re.uid).first
      if provider.try(:user)
        user = provider.user
      else
        user = self.initialize_from_omniauth(request_env)
        unless user.email.nil?
          if u = User.where(:email => user.email).first
            user = u.create_provider_from_omniauth!(request_env)
          end
        end
      end
      return user
    end

    def initialize_from_omniauth(request_env)
			re = JSON.parse(request_env.to_json, object_class: OpenStruct)
      user = User.new
      # try to grep the email returned by request.env
      user.password = Devise.friendly_token[0,20]
      case re.provider
      when "facebook"
        user.email = re.info.email
        user.full_name = re.info.name
      when "google_oauth2"
        user.email = re.info.email
        user.full_name = re.info.name
      end
      return user
    end

  end

  def create_provider_from_omniauth!(request_env)
		re = JSON.parse(request_env.to_json, object_class: OpenStruct)
		self.skip_confirmation! if Devise.mappings[:user].confirmable?
		self.save!
		self.providers.create!(:provider => re.provider, :uid => re.uid, :access_token => re.credentials.token, :access_secret => re.credentials.secret)
  end

end
