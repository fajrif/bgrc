# Loaded after configatron.rb. Every absolute URL — email links, payment gateway return URLs, url helpers
# used outside a request — is built from SITE_URL (configatron.site_url), so each server sets its own
# public address in .env instead of in code.
module SiteUrl
	def self.url_options
		raw = configatron.site_url.to_s
		uri = URI.parse(raw.start_with?("http") ? raw : "http://#{raw}")
		options = { protocol: uri.scheme, host: uri.host }
		options[:port] = uri.port unless [80, 443].include?(uri.port)
		options
	end
end

if Rails.env.production? && ENV["SITE_URL"].blank?
	Rails.logger.warn("[site_url] SITE_URL is not set; absolute URLs use #{configatron.site_url}")
end

Rails.application.config.action_mailer.default_url_options = SiteUrl.url_options
ActiveSupport.on_load(:action_mailer) { self.default_url_options = SiteUrl.url_options }
Rails.application.routes.default_url_options = SiteUrl.url_options
