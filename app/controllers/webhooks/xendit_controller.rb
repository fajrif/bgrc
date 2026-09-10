module Webhooks
	# Invoice callbacks: invoice.paid and invoice.expired. Xendit retries anything
	# that is not 2xx, which is why Purchase#apply_gateway_result! is idempotent.
	class XenditController < BaseController
		private

		def gateway
			PaymentGateways::Xendit
		end

		def external_id
			payload["external_id"]
		end
	end
end
