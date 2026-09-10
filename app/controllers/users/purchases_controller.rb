class Users::PurchasesController < Users::BaseController
	before_action :set_productable

	# What may be paid for, keyed by the `type` segment the payment links use.
	# Replaces a `constantize` on raw user input.
	PAYABLE_TYPES = {
		"booking" => "Booking",
		"golf_reservation" => "GolfReservation",
		"food_order" => "FoodOrder",
		"class_credit_purchase" => "ClassCreditPurchase",
	}.freeze

	# The products that carry a payment window.
	TIMED_TYPES = %w[Booking GolfReservation FoodOrder].freeze

	# Opens a checkout and hands the browser somewhere to pay. The result of that
	# payment comes back over a verified webhook (Webhooks::BaseController) — never
	# from the browser, which is why there is no longer a #create here.
	def new
		if timed_product? && @productable.payment_window_expired?
			return render_payment_error("The time limit for payment has expired.")
		end

		return redirect_to users_bookings_path unless request.format.js?

		if (settled = existing_paid_purchase)
			@purchase = settled
			return render_payment_error("This has already been paid for.")
		end

		@purchase = build_purchase
		@purchase.start_checkout!

		respond_to { |format| format.js }
	rescue StandardError => e
		Rails.logger.error(
			"[checkout] #{@productable.class}##{@productable.id} failed: #{e.class} #{e.message}"
		)
		render_payment_error(checkout_error_message(e))
	end

	private

	def timed_product?
		TIMED_TYPES.include?(@productable.class.name)
	end

	def existing_paid_purchase
		Purchase.where(productable: @productable)
		        .where(status_code: Purchase::SUCCESS_CODES)
		        .first
	end

	# A previous unfinished attempt is replaced rather than reused: its checkout URL
	# may point at an invoice that has since expired at the gateway.
	def build_purchase
		Purchase.find_by(
			productable: @productable,
			user: current_user,
			status_code: Purchase::INITIALIZED_CODE,
		)&.destroy

		Purchase.create!(
			productable: @productable,
			user: current_user,
			status_code: Purchase::INITIALIZED_CODE,
		)
	end

	def render_payment_error(message)
		flash.now[:alert] = message
		respond_to { |format| format.js { render :error } }
	end

	# Gateway internals are logged, not shown.
	def checkout_error_message(error)
		case error
		when PaymentGateways::ConfigurationError
			"Online payment is unavailable right now. Please contact us to complete your booking."
		when PaymentGateways::RequestError
			"We could not reach the payment provider. Please try again in a moment."
		else
			"We could not start your payment. Please try again."
		end
	end

	def set_productable
		model = PAYABLE_TYPES[params[:type].to_s]
		raise ActionController::RoutingError, "Unknown product type" if model.nil?

		@productable = model.constantize.find(params[:id])
	end

end
