module PaymentPanelHelper
	# Policy snippets shown before paying, per product. Each entry lists snippet keys in order of
	# preference, so golf can have its own wording and fall back to the general policy.
	DISCLAIMERS = {
		"booking" => {
			title: "Terms & Conditions",
			keys: [%w[cancellation_policy], %w[refund_policy], %w[terms_and_conditions]],
		},
		"golf_reservation" => {
			title: "Golf Reservation Terms & Conditions",
			keys: [%w[golf_cancellation_policy cancellation_policy], %w[golf_refund_policy refund_policy], %w[golf_terms terms_and_conditions]],
		},
		"food_order" => {
			title: "Before You Pay",
			keys: [%w[cancellation_policy], %w[refund_policy], %w[terms_and_conditions]],
		},
		"class_credit_purchase" => {
			title: "Terms & Conditions",
			keys: [%w[cancellation_policy], %w[refund_policy], %w[terms_and_conditions]],
		},
	}.freeze

	# The Vue payment panel (app/frontend/components/payment/PaymentPanel.vue) for an unpaid order:
	# the countdown, Pay (policies, then checkout), Cancel, and for guests the sign-in / register /
	# verify modal. Only rendered while the order is unpaid; the page's ERB covers every other state.
	def payment_panel(record, cancel_path:, back_path:, back_label:, intro: nil)
		type = record.class.name.underscore

		props = {
			type: type,
			orderId: record.order_id,
			status: record.payable_status,
			secondsRemaining: record.time_remaining,
			signedIn: user_signed_in?,
			statusUrl: api_payment_status_path(type: type, id: record.order_id),
			checkoutUrl: api_checkout_path(type: type, id: record.order_id),
			cancelUrl: cancel_path,
			backUrl: back_path,
			backLabel: back_label,
			disclaimer: payment_disclaimer(type, intro: intro),
			auth: {
				sessionUrl: api_session_path,
				registrationUrl: api_registration_path,
				verificationUrl: api_verification_path,
				resendUrl: api_resend_verification_path,
				googleUrl: user_google_oauth2_omniauth_authorize_path,
				forgotPasswordUrl: new_user_password_path,
			},
		}

		vue_component("PaymentPanel", props, class: "bbcc-payment-panel-mount") do
			tag.p("Loading payment options…", class: "text-medium mb-0")
		end
	end

	private

	def payment_disclaimer(type, intro:)
		config = DISCLAIMERS.fetch(type)
		sections = config[:keys].filter_map do |candidates|
			snippet = candidates.lazy.filter_map { |key| Snippet.find_by_key(key) }.first
			{ title: snippet.title, html: snippet.content.to_s } if snippet
		end

		{ title: config[:title], intro: intro, sections: sections }.compact
	end
end
