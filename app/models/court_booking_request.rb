# One visitor's intended court booking — a slot plus add-ons — validated and priced the way it will
# actually be saved. Api::CourtBookingsController quotes it for the sidebar and books it on submit,
# so the total shown is the total charged. Prices never come from the browser.
class CourtBookingRequest
	include ActiveModel::Validations

	BOOKING_HORIZON = 14.days
	MAX_ADD_ON_QUANTITY = 6
	UNAVAILABLE_MESSAGE = "Sorry, that time has just been booked. Please choose another slot.".freeze

	attr_reader :court, :start, :duration, :add_ons

	validate :slot_must_be_bookable

	# `start` is wall-clock "YYYY-MM-DD HH:MM"; `add_ons` is { item_id => quantity }.
	def initialize(court:, start:, duration:, add_ons: {})
		@court = court
		@start = (DateTime.strptime(start.to_s, "%Y-%m-%d %H:%M") rescue nil)
		@duration = duration.to_i
		@add_ons = normalise_add_ons(add_ons)
	end

	# Checked fresh every call: the answer can change between the quote and the booking.
	def available?
		Booking.check_available_dates?(court.id, start.strftime("%d/%m/%Y %H:%M"), duration)
	end

	def court_fee
		@court_fee ||= court.calculate_price(start, duration, false)
	end

	def total
		court_fee + add_ons.sum { |item, quantity| add_on_amount(item, quantity) }
	end

	# Books the slot, or returns nil if someone took it first. The availability check and the save
	# share a lock on the court, so two people submitting the same slot cannot both get it. Pax and
	# court type come from the bookings table's column defaults.
	def book!(user:)
		Booking.transaction do
			court.lock!
			raise ActiveRecord::Rollback unless available?

			booking = Booking.create!(court: court, user: user, date: start, duration: duration)
			add_ons.each { |item, quantity| booking.add_ons.create!(item: item, quantity: quantity) }
			# calculate_prices sums the add-ons, which only exist after the first save.
			booking.save! if add_ons.any?
			booking
		end
	end

	def as_json(*)
		return { bookable: false, message: errors.full_messages.first } if start.nil? || duration <= 0

		bookable = errors.empty? && available?
		{
			court: court.name_label,
			date_label: start.strftime("%a, %d %b %Y · %H:%M"),
			duration_label: duration_label,
			court_fee_label: currency(court_fee),
			lines: add_ons.map { |item, quantity| { label: "#{item.name} (#{quantity}x)", amount: add_on_amount(item, quantity).to_i, amount_label: currency(add_on_amount(item, quantity)) } },
			total: total.to_i,
			total_label: currency(total),
			event_title: event_title,
			bookable: bookable,
			message: errors.full_messages.first || (UNAVAILABLE_MESSAGE unless bookable),
		}
	end

	private

	def slot_must_be_bookable
		if start.nil? || duration <= 0
			errors.add(:base, "Please select the times you want on the calendar.")
		elsif start.minute != 0
			errors.add(:base, "Bookings start on the hour.")
		elsif start < ClubTime.now
			errors.add(:base, "Cannot book a time slot in the past.")
		elsif start > ClubTime.now + BOOKING_HORIZON
			errors.add(:base, "Bookings can only be made up to 14 days in advance. Please contact us via WhatsApp for special requests.")
		elsif start + duration.hours > (start.to_date + 1).to_datetime
			errors.add(:base, "A booking must end on the day it starts.")
		elsif duration < court.min_duration
			errors.add(:base, "This court's minimum booking is #{court.min_duration} #{'hour'.pluralize(court.min_duration)}.")
		end
	end

	# Only real items, each at a quantity the stepper allows.
	def normalise_add_ons(raw)
		quantities = raw.to_h.to_h { |id, quantity| [id.to_s, quantity.to_i] }.select { |_, quantity| quantity.positive? }
		Item.where(id: quantities.keys).map { |item| [item, quantities.fetch(item.id.to_s).clamp(1, MAX_ADD_ON_QUANTITY)] }
	end

	# Same arithmetic as AddOn#total_price: per hour of the booking.
	def add_on_amount(item, quantity)
		item.price * quantity * duration
	end

	def duration_label
		"#{duration} #{'hour'.pluralize(duration)}"
	end

	# The short label on the selected block in the calendar, as the old page showed it.
	def event_title
		short = ActionController::Base.helpers.number_to_human(total, format: "Rp.%n%u", units: { thousand: "K", million: "M" })
		duration > 1 ? "Book #{duration_label} #{short}" : short
	end

	def currency(amount)
		ActionController::Base.helpers.number_to_currency(amount, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end
end
