require 'net/https'

module Bgrc
	class Recaptcha

		RECAPTCHA_MINIMUM_SCORE = 0.7

		def self.verify_recaptcha?(token, recaptcha_action)
			secret_key = ENV["RECAPTCHA_V3_SECRET_KEY"]

			uri = URI.parse("https://www.google.com/recaptcha/api/siteverify?secret=#{secret_key}&response=#{token}")
			response = Net::HTTP.get_response(uri)
			json = JSON.parse(response.body)
			json['success'] && json['score'] >= Bgrc::Recaptcha::RECAPTCHA_MINIMUM_SCORE && json['action'] == recaptcha_action
		end

		def self.verify_recaptcha_v2?(token, recaptcha_action)
			secret_key = ENV["RECAPTCHA_V2_SECRET_KEY"]

			uri = URI.parse("https://www.google.com/recaptcha/api/siteverify?secret=#{secret_key}&response=#{token}")
			response = Net::HTTP.get_response(uri)
			json = JSON.parse(response.body)
			json['success']
		end

		def self.recaptcha_execute(action)
			id = "recaptcha_token_#{SecureRandom.hex(10)}"
			site_key = ENV["RECAPTCHA_V3_SITE_KEY"]

			return %Q{
				<input name="recaptcha_token" type="hidden" id="#{id}"/>
				<script>
					grecaptcha.ready(function() {
						grecaptcha.execute('#{site_key}', {action: '#{action}'}).then(function(token) {
							document.getElementById("#{id}").value = token;
						});
					});
				</script>
			}
		end

		def self.recaptcha_v2_render
			id = "recaptcha_widget_#{SecureRandom.hex(10)}"
			site_key = ENV["RECAPTCHA_V2_SITE_KEY"]

			return %Q{
				<div id="#{id}"></div>
				<script>
					grecaptcha.ready(function() {
						grecaptcha.render('#{id}', {
							 'sitekey' : '#{site_key}'
						});
					});
				</script>
			}
		end

	end
end
