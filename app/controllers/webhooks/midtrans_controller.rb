module Webhooks
	# Midtrans HTTP notifications, used when PAYMENT_GATEWAY is rolled back to
	# midtrans. Set this URL as the Payment Notification URL in the Midtrans
	# dashboard; without it, Midtrans payments are never recorded.
	class MidtransController < BaseController
		private

		def gateway
			PaymentGateways::Midtrans
		end

		def external_id
			payload["order_id"]
		end
	end
end
