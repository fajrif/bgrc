module Webhooks
	# Server-to-server payment notifications.
	#
	# Inherits ActionController::Base rather than ApplicationController on purpose:
	# a gateway is not a signed-in user and carries no CSRF token, so neither Devise
	# nor forgery protection applies. Authenticity comes from the gateway's own
	# verification instead, and nothing here trusts the request body until that
	# passes.
	class BaseController < ActionController::Base
		skip_forgery_protection

		def create
			unless gateway.verify_callback(request)
				Rails.logger.warn("[#{gateway_name}] rejected callback: bad or missing verification")
				return head :unauthorized
			end

			purchase = Purchase.find_by(order_id: external_id)
			if purchase.nil?
				# Deliberately 2xx: retrying will never conjure a row we do not have.
				Rails.logger.info("[#{gateway_name}] callback for unknown order #{external_id.inspect}")
				return head :ok
			end

			result = gateway.normalize_callback(payload)
			outcome = purchase.apply_gateway_result!(result, payload: payload)
			Rails.logger.info("[#{gateway_name}] #{external_id}: #{result.outcome} -> #{outcome}")

			head :ok
		rescue StandardError => e
			Rails.logger.error("[#{gateway_name}] callback failed for #{external_id.inspect}: #{e.class} #{e.message}")
			# 5xx so the gateway retries. The money moved even if we failed to record it.
			head :internal_server_error
		end

		private

		def gateway
			raise NotImplementedError
		end

		def external_id
			raise NotImplementedError
		end

		def gateway_name
			self.class.name.demodulize.sub("Controller", "").downcase
		end

		# The parsed JSON body, without Rails' :controller/:action additions.
		def payload
			@payload ||= request.request_parameters.presence || {}
		end
	end
end
