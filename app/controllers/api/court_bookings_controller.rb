module Api
	# Quotes and creates court bookings for the Vue booking calendar (CourtBookingApp). Both go through
	# CourtBookingRequest, so the total in the sidebar is exactly what the booking is saved at.
	class CourtBookingsController < BaseController
		def quote
			booking_request.valid?
			render json: booking_request
		end

		def create
			return render_error(booking_request.errors.full_messages.first) unless booking_request.valid?

			booking = booking_request.book!(user: current_user)
			return render_error(CourtBookingRequest::UNAVAILABLE_MESSAGE, status: :conflict) if booking.nil?

			track_guest_order!(booking) unless user_signed_in?
			render json: { order_id: booking.order_id, redirect_url: booking_path(id: booking.order_id) }, status: :created
		end

		private

		def booking_request
			@booking_request ||= CourtBookingRequest.new(
				court: Court.find(params[:id]),
				start: params[:start],
				duration: params[:duration],
				add_ons: params[:add_ons].respond_to?(:to_unsafe_h) ? params[:add_ons].to_unsafe_h : {},
			)
		end
	end
end
