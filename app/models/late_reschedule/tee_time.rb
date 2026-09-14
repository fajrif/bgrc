module LateReschedule
	# A tee time moves to another tee time on the same course with room for the whole party, keeping its
	# players, holes and add-ons, within the normal 30-day booking window.
	class TeeTime < Base
		HORIZON = GolfReservationRequest::BOOKING_HORIZON
		FULL_MESSAGE = "Sorry, that tee time no longer has room for your party. Please choose another.".freeze

		attr_reader :reservation, :tee_time

		validate :new_tee_time_must_be_bookable

		# `tee_time` is wall-clock "YYYY-MM-DD HH:MM".
		def initialize(reservation, tee_time:)
			@reservation = reservation
			@tee_time = self.class.parse_time(tee_time)
		end

		def course
			reservation.golf_course
		end

		def apply!
			moved = GolfReservation.transaction do
				reservation.lock!
				fail_with!(ALREADY_MOVED_MESSAGE) unless reservation.needs_reschedule?
				course.lock!
				fail_with!(FULL_MESSAGE) unless GolfReservation.check_available?(course, tee_time, reservation.players_count, excluding: reservation)

				# Another tee time may carry another rate; the customer keeps what they paid.
				reservation.keep_paid_price = true
				reservation.update!(tee_time: tee_time, status: GolfReservation::PAID)
			end
			!!moved
		end

		def notify!
			reservation.send_email_notification!
		end

		def confirmation_notice
			"Your tee time is confirmed for #{tee_time.strftime('%a %d %b %Y, %H:%M')}."
		end

		def redirect_path
			routes.users_bookings_path
		end

		private

		def new_tee_time_must_be_bookable
			if tee_time.nil?
				errors.add(:base, "Please select a tee time.")
			elsif tee_time < Time.current
				errors.add(:base, "This tee time has already passed. Please select another slot.")
			elsif tee_time > HORIZON.from_now
				errors.add(:base, "Tee times can only be booked up to 30 days in advance.")
			elsif !on_tee_sheet?
				errors.add(:base, "That is not one of the course's tee times. Please select a slot from the list.")
			end
		end

		def on_tee_sheet?
			wanted = tee_time.strftime("%H:%M")
			course.available_tee_times(tee_time.to_date).any? { |slot| slot[:time].strftime("%H:%M") == wanted }
		end
	end
end
