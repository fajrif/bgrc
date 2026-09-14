# A late payment whose slot was taken meanwhile (NEEDS_RESCHEDULE), moved by its customer to a new time
# at the price already paid — BBCC does not refund. LateReschedule::CourtBooking, ::TeeTime and
# ::ClassSession each validate the new time, take it under a lock and confirm the order. A move is not a
# customer reschedule: it never counts toward max_reschedule_count, and there is no deadline for it.
module LateReschedule
	ALREADY_MOVED_MESSAGE = "This booking already has a new time.".freeze
	NOT_PENDING_MESSAGE = "There is nothing to reschedule for this order.".freeze
	TYPES = %w[booking golf_reservation class_credit_purchase].freeze

	# The user's record waiting for a new time — a Booking, GolfReservation or GroupClassRegistration —
	# or nil. `type` and `order_id` are what LateReschedule.address gives.
	def self.pending_record(user, type, order_id)
		case type.to_s
		when "booking"
			user.bookings.find_by(order_id: order_id.to_s, status: Booking::NEEDS_RESCHEDULE)
		when "golf_reservation"
			user.golf_reservations.find_by(order_id: order_id.to_s, status: GolfReservation::NEEDS_RESCHEDULE)
		when "class_credit_purchase"
			user.class_credit_purchases.find_by(order_id: order_id.to_s)
			    &.group_class_registrations&.find_by(status: GroupClassRegistration::NEEDS_RESCHEDULE)
		end
	end

	# The move for a pending record, built from the request's params.
	def self.for(record, params)
		case record
		when Booking then CourtBooking.new(record, court_id: params[:court_id], start: params[:start])
		when GolfReservation then TeeTime.new(record, tee_time: params[:tee_time])
		when GroupClassRegistration then ClassSession.new(record, session_start: params[:session_start])
		end
	end

	# [type, order_id] for URLs. A class session is addressed through the credit purchase that paid for it.
	def self.address(record)
		case record
		when Booking then ["booking", record.order_id]
		when GolfReservation then ["golf_reservation", record.order_id]
		when GroupClassRegistration then ["class_credit_purchase", record.class_credit_purchase&.order_id]
		when ClassCreditPurchase then ["class_credit_purchase", record.order_id]
		end
	end

	# What was paid for and when, for the customer's email and the reschedule page.
	def self.summary(record)
		case record
		when Booking
			{ kind: "Court booking", order_id: record.order_id, original_time: record.date, amount: record.total_price_label,
			  description: record.court.try(:name_label) || record.court.try(:name) }
		when GolfReservation
			{ kind: "Tee time", order_id: record.order_id, original_time: record.tee_time, amount: record.total_price_label,
			  description: "#{record.golf_course.try(:name)} — #{record.players_count} players, #{record.holes_label}" }
		when GroupClassRegistration
			{ kind: "Class session", order_id: record.class_credit_purchase.try(:order_id), original_time: record.session_date,
			  amount: record.class_credit_purchase.try(:price_label), description: record.group_class.try(:name) }
		end
	end
end
