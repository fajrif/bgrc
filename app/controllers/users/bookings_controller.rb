class Users::BookingsController < Users::BaseController

	def index
		current_user.remove_all_unpaid_bookings
		@bookings = current_user.current_bookings
	end

	def create
		# Find associated court
		@court = Court.find(params[:court_id])
		dates = params[:dates]
		duration = params[:duration]

		if dates.blank? or duration.blank?
			redirect_to court_path(@court), :alert => "Please select the timetable below and press the submit button."
		else
			if Booking.check_available_dates?(@court.id, dates, duration)
				@booking = Booking.new(court: @court, user: current_user, date: DateTime::strptime(dates,"%d/%m/%Y %H:%M"), duration: duration)
				if @booking.save
					# Save and redirect to court show path
					redirect_to users_bookings_path, :notice => "Court booking added to your booking schedules!"
				else
					redirect_to court_path(@court), :alert => "Oops cannot booking this court!"
				end
			else
				redirect_to court_path(@court), :alert => "Oops sorry booking dates not available"
			end
		end
	end

	def destroy
		@booking = current_user.bookings.find(params[:id])
		@booking.destroy

		redirect_to users_bookings_path, :alert => "Booking canceled."
	end

	def history
		@bookings = current_user.paid_bookings.page(params[:page]).per(10)
	end

end
