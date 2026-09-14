module Api
	# JSON endpoints for the Vue components in app/frontend. They share the HTML pages' session
	# cookie, so they keep CSRF protection — lib/api.ts sends the token from the csrf-token meta tag.
	class BaseController < ApplicationController
		# A missing or stale token must fail loudly; the inherited :null_session would instead run
		# the action as a signed-out visitor.
		protect_from_forgery with: :exception

		skip_before_action :set_footer_inquiry

		before_action { request.format = :json }

		rescue_from ActiveRecord::RecordNotFound do
			render_error("Not found.", status: :not_found)
		end

		rescue_from ActionController::InvalidAuthenticityToken do
			render_error("Your session has expired. Please refresh the page and try again.", status: :unprocessable_entity)
		end

		# What may be paid for, keyed by the `type` segment of the URL. Replaces a
		# `constantize` on raw user input. Every one of them carries a PaymentWindow.
		PAYABLE_TYPES = {
			"booking"               => "Booking",
			"golf_reservation"      => "GolfReservation",
			"food_order"            => "FoodOrder",
			"class_credit_purchase" => "ClassCreditPurchase",
		}.freeze

		private

		# Every error body has this shape; app/frontend/types/api.ts#ApiErrorBody mirrors it.
		def render_error(message, status: :unprocessable_entity, errors: nil, **extra)
			render json: { error: message, errors: errors, **extra }.compact, status: status
		end

		def require_user!
			render_error("Please sign in to continue.", status: :unauthorized) unless user_signed_in?
		end

		# Orders are addressed by type and order_id, never by a guessable sequential id.
		def find_payable!
			model = PAYABLE_TYPES[params[:type].to_s] or raise ActiveRecord::RecordNotFound
			model.constantize.unscoped.find_by!(order_id: params[:id].to_s)
		end

		# The same people who can open the order's page: its owner, or the guest session that created
		# it. Bookings, tee times and food orders keep their pages' rule that a signed-in visitor may
		# claim an order nobody owns yet; class credits never had it.
		def can_view_payable?(record)
			return user_signed_in? && record.user_id == current_user.id if record.user_id.present?

			session_owns?(record) || (user_signed_in? && !record.is_a?(ClassCreditPurchase))
		end

		# A failed email must not look like a code that is on its way, and must not start the cooldown.
		def send_code(user)
			user.send_verification_code!
			true
		rescue StandardError => e
			Rails.logger.error("[verification] could not email a code to user #{user.id}: #{e.class} #{e.message}")
			user.update_columns(verification_code_sent_at: nil)
			false
		end
	end
end
