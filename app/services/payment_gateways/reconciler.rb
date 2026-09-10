module PaymentGateways
	# Settles purchases the gateway completed but we never heard about — a customer
	# who closed the tab mid-payment, or a webhook that never arrived.
	#
	# Asks the gateway about each pending purchase and funnels the answer through
	# the same idempotent Purchase#apply_gateway_result! the webhook uses, so
	# running this twice, or racing it against a webhook, is harmless.
	class Reconciler
		DEFAULT_LOOKBACK = 7.days

		def self.call(...) = new(...).call

		def initialize(lookback: DEFAULT_LOOKBACK, logger: Rails.logger, io: nil)
			@lookback = lookback
			@logger = logger
			@io = io
		end

		# Returns a Hash of outcome => count.
		def call
			counts = Hash.new(0)

			scope.find_each do |purchase|
				counts[reconcile(purchase)] += 1
			end

			counts
		end

		def scope
			Purchase.through_gateway.awaiting_payment.where(created_at: @lookback.ago..)
		end

		private

		def reconcile(purchase)
			result = purchase.gateway.fetch_status(purchase)
			return :unknown if result.nil?

			outcome = purchase.apply_gateway_result!(result)
			if outcome == :settled
				report("settled #{purchase.order_id} (#{purchase.payment_gateway})")
			end
			outcome
		rescue StandardError => e
			@logger.error("[reconcile] #{purchase.order_id}: #{e.class} #{e.message}")
			report("error #{purchase.order_id}: #{e.class} #{e.message}")
			:error
		end

		def report(message)
			@logger.info("[reconcile] #{message}")
			@io&.puts(message)
		end
	end
end
