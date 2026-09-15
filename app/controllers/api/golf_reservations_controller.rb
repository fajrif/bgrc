module Api
	# Quotes and creates tee-time reservations for the Vue golf booking page (GolfBookingApp), always on the
	# bookable course (GolfCourse.current). Both go through GolfReservationRequest, so the total in the form
	# is exactly what the reservation is saved at.
	class GolfReservationsController < BaseController
		before_action :require_open_course

		def quote
			reservation_request.valid?
			render json: reservation_request
		end

		def create
			return render_error(reservation_request.errors.full_messages.first) unless reservation_request.valid?

			reservation = reservation_request.book!(user: current_user)
			return render_error(reservation_request.capacity_message, status: :conflict) if reservation.nil?

			track_guest_order!(reservation) unless user_signed_in?
			render json: { order_id: reservation.order_id, redirect_url: golf_reservation_path(id: reservation.order_id) }, status: :created
		end

		private

		def require_open_course
			@course = GolfCourse.current
			render_error("Golf bookings are not open right now. Please contact us.", status: :not_found) if @course.nil?
		end

		def reservation_request
			@reservation_request ||= GolfReservationRequest.new(
				course: @course,
				tee_time: params[:tee_time],
				players_count: params[:players_count],
				holes: params[:holes],
				player_names: params[:player_names],
				notes: params[:notes],
				add_on_ids: params[:add_on_ids],
			)
		end
	end
end
