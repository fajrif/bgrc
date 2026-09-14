module Api
	# Opens a gateway checkout for an order and tells the browser where to go. The payment's result
	# still arrives by webhook (Webhooks::BaseController), never from here.
	class CheckoutsController < BaseController
		before_action :require_user!

		def create
			record = find_payable!
			return render_error("Not found.", status: :not_found) unless record.user_id == current_user.id

			if record.payable_status == "paid" || Purchase.where(productable: record, status_code: Purchase::SUCCESS_CODES).exists?
				return render_error("This has already been paid for.", status: :conflict)
			end
			unless record.payment_window_open?
				return render_error("The time limit for payment has expired.", status: :gone)
			end

			# Once the customer is on the gateway's page the hold must outlast the invoice: starting
			# checkout extends it (once) and the invoice is given the same deadline.
			record.extend_for_checkout!
			purchase = replace_unfinished_purchase(record)
			purchase.start_checkout!

			render json: { checkout_url: purchase.checkout_url.presence, snap_token: purchase.token.presence }.compact
		rescue PaymentGateways::ConfigurationError => e
			log_failure(record, e)
			render_error("Online payment is unavailable right now. Please contact us to complete your order.", status: :service_unavailable)
		rescue PaymentGateways::RequestError => e
			log_failure(record, e)
			render_error("We could not reach the payment provider. Please try again in a moment.", status: :bad_gateway)
		rescue PaymentGateways::Error => e
			log_failure(record, e)
			render_error("We could not start your payment. Please try again.")
		end

		private

		# A previous unfinished attempt is replaced rather than reused: its checkout URL may point at an
		# invoice that has since expired. The old invoice is voided first so both cannot be paid.
		def replace_unfinished_purchase(record)
			stale = Purchase.find_by(productable: record, user: current_user, status_code: Purchase::INITIALIZED_CODE)
			stale&.expire_checkout!
			stale&.destroy

			Purchase.create!(productable: record, user: current_user, status_code: Purchase::INITIALIZED_CODE)
		end

		def log_failure(record, error)
			Rails.logger.error("[checkout] #{record.class}##{record.id} failed: #{error.class} #{error.message}")
		end
	end
end
