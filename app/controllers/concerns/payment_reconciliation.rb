# Closes the gap between a customer returning from the gateway and the webhook
# that actually settles their purchase.
#
# The webhook is still the authority — this only asks the gateway the same
# question a moment earlier, and funnels the answer through the same idempotent
# Purchase#apply_gateway_result!. If the fetch fails, nothing breaks: the webhook
# or the reconcile sweep will settle it.
module PaymentReconciliation
	extend ActiveSupport::Concern

	private

	def settle_pending_payment!(productable)
		return if productable.blank? || params[:payment].blank?

		if params[:payment] == "failed"
			flash.now[:alert] = "Your payment was not completed. You can try again below."
			return
		end

		return unless params[:payment] == "success"

		purchase = Purchase.where(productable: productable).awaiting_payment.first
		if purchase.nil? || purchase.cashier?
			# Already settled by the webhook before the redirect landed.
			flash.now[:notice] = "Payment received. Thank you!"
			return
		end

		result = purchase.gateway.fetch_status(purchase)
		if result.nil?
			flash.now[:notice] = "We are still confirming your payment. Refresh in a moment."
			return
		end

		case purchase.apply_gateway_result!(result)
		when :settled, :already_settled
			productable.reload
			flash.now[:notice] = "Payment received. Thank you!"
		when :expired
			productable.reload
			flash.now[:alert] = "This payment expired before it completed."
		else
			flash.now[:notice] = "We are still confirming your payment. Refresh in a moment."
		end
	rescue StandardError => e
		Rails.logger.warn(
			"[payment-return] #{productable.class}##{productable.id}: #{e.class} #{e.message}"
		)
		flash.now[:notice] = "We are still confirming your payment. Refresh in a moment."
	end
end
