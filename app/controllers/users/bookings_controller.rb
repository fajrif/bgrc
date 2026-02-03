class Users::BookingsController < Users::BaseController

	def index
		Booking.expire_stale_bookings!
		criteria = current_user.current_bookings

		@bookings = criteria.page(params[:page]).per(10)
	end

	def destroy
		@booking = current_user.bookings.find(params[:id])
		@booking.cancel!

		redirect_to users_bookings_path, alert: "Booking cancelled."
	end

	def history
		Booking.expire_stale_bookings!
		@bookings = current_user.booking_history.page(params[:page]).per(10)
	end

end
