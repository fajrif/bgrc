module LateReschedule
	# A court booking moves to any court of the same sport and court type (Indoor, Outdoor…), for the same
	# number of hours, within the normal 14-day booking window.
	class CourtBooking < Base
		HORIZON = CourtBookingRequest::BOOKING_HORIZON

		attr_reader :booking, :court, :start

		validate :new_time_must_be_bookable

		def self.courts_for(booking)
			Court.where(sport_id: booking.court.sport_id, court_type_id: booking.court.court_type_id).order(:id)
		end

		# `start` is wall-clock "YYYY-MM-DD HH:MM". Courts outside the booking's sport and type are ignored.
		def initialize(booking, court_id:, start:)
			@booking = booking
			@court = self.class.courts_for(booking).find_by(id: court_id)
			@start = self.class.parse_time(start)
		end

		def duration
			booking.duration
		end

		def apply!
			moved = Booking.transaction do
				booking.lock!
				fail_with!(ALREADY_MOVED_MESSAGE) unless booking.needs_reschedule?
				court.lock!
				unless Booking.check_available_dates?(court.id, start.strftime("%d/%m/%Y %H:%M"), duration, booking.id)
					fail_with!(CourtBookingRequest::UNAVAILABLE_MESSAGE)
				end

				# The new court may have another hourly rate; the customer keeps what they paid.
				booking.keep_paid_price = true
				booking.update!(court: court, date: start, end_date: start + duration.hours, status: Booking::PAID)
			end
			!!moved
		end

		def notify!
			booking.send_email_notification!
		end

		def confirmation_notice
			"Your booking is confirmed for #{start.strftime('%a %d %b %Y, %H:%M')} on #{court.name}."
		end

		def redirect_path
			routes.users_bookings_path
		end

		private

		def new_time_must_be_bookable
			if court.nil?
				errors.add(:base, "Please choose a court.")
			elsif start.nil?
				errors.add(:base, "Please select a new time on the calendar.")
			elsif start.minute != 0
				errors.add(:base, "Bookings start on the hour.")
			elsif start < Time.current
				errors.add(:base, "Cannot book a time slot in the past.")
			elsif start > HORIZON.from_now
				errors.add(:base, "Bookings can only be made up to 14 days in advance.")
			elsif start + duration.hours > (start.to_date + 1).to_datetime
				errors.add(:base, "A booking must end on the day it starts.")
			end
		end
	end
end
