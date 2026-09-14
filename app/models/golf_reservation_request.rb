# One visitor's intended tee time — players, holes, optional names and notes, and add-ons —
# validated and priced the way it will actually be saved. Api::GolfReservationsController quotes it
# in the reservation form and books it on submit, so the total shown is the total charged. Prices
# never come from the browser.
class GolfReservationRequest
	include ActiveModel::Validations

	BOOKING_HORIZON = 30.days
	MAX_PLAYERS = 4 # GolfReservation validates the same ceiling
	MAX_NOTES_LENGTH = 255

	attr_reader :course, :tee_time, :players_count, :holes, :player_names, :notes, :items

	validate :tee_time_must_be_bookable

	# `tee_time` is wall-clock "YYYY-MM-DD HH:MM"; `add_on_ids` are GolfItem ids, each taken once.
	def initialize(course:, tee_time:, players_count:, holes:, player_names: [], notes: nil, add_on_ids: [])
		@course = course
		@tee_time = (DateTime.strptime(tee_time.to_s, "%Y-%m-%d %H:%M") rescue nil)
		@players_count = players_count.to_i
		@holes = holes.to_i
		@player_names = Array(player_names).map { |name| name.to_s.strip }.reject(&:blank?).first(@players_count)
		@notes = notes.to_s.strip.presence
		@items = course.golf_items.active.where(id: Array(add_on_ids)).order(:name).to_a
	end

	def max_players
		[course.max_players.to_i, MAX_PLAYERS].min
	end

	def remaining
		GolfReservation.remaining_capacity_for(course, tee_time)
	end

	def rate
		@rate ||= GolfRate.find_rate(course, holes, tee_time)
	end

	def green_fee
		rate * players_count
	end

	def total
		green_fee + items.sum { |item| add_on_amount(item) }
	end

	def capacity_message
		left = remaining
		return "Sorry, that tee time is fully booked." if left.zero?

		"Only #{left} spot#{'s' unless left == 1} remaining for that tee time — please choose a smaller party size or another slot."
	end

	# Books the tee time, or returns nil if the party no longer fits. The capacity check and the save
	# share a lock on the course, so two parties cannot both take its last places.
	def book!(user:)
		GolfReservation.transaction do
			course.lock!
			raise ActiveRecord::Rollback unless GolfReservation.check_available?(course, tee_time, players_count)

			reservation = GolfReservation.create!(golf_course: course, user: user, tee_time: tee_time,
			                                      players_count: players_count, holes: holes,
			                                      notes: notes, player_names: player_names)
			items.each { |item| reservation.golf_add_ons.create!(golf_item: item, quantity: 1) }
			# calculate_prices sums the add-ons, which only exist after the first save.
			reservation.save! if items.any?
			reservation
		end
	end

	def as_json(*)
		return { bookable: false, message: errors.full_messages.first } if tee_time.nil?

		left = remaining
		fits = players_count <= left
		bookable = errors.empty? && fits
		{
			tee_time_label: tee_time.strftime("%A, %d %b %Y — %H:%M"),
			holes_label: "#{holes} Holes",
			players_label: "#{players_count} #{'player'.pluralize(players_count)}",
			remaining: left,
			rate_label: "#{currency(rate)} / player",
			green_fee_label: currency(green_fee),
			lines: items.map do |item|
				label = item.per_person? ? "#{item.name} (× #{players_count})" : item.name
				{ label: label, amount: add_on_amount(item).to_i, amount_label: currency(add_on_amount(item)) }
			end,
			total: total.to_i,
			total_label: currency(total),
			bookable: bookable,
			message: errors.full_messages.first || (capacity_message unless fits),
		}
	end

	private

	def tee_time_must_be_bookable
		if tee_time.nil?
			errors.add(:base, "Please select a tee time.")
		elsif tee_time < Time.current
			errors.add(:base, "This tee time has already passed. Please select another slot.")
		elsif tee_time > BOOKING_HORIZON.from_now
			errors.add(:base, "Bookings can only be made up to 30 days in advance.")
		elsif !on_tee_sheet?
			errors.add(:base, "That is not one of the course's tee times. Please select a slot from the list.")
		elsif !players_count.between?(1, max_players)
			errors.add(:base, "Please choose between 1 and #{max_players} players.")
		elsif !course.holes_list.include?(holes)
			errors.add(:base, "Please choose #{course.holes_list.to_sentence(two_words_connector: ' or ', last_word_connector: ' or ')} holes.")
		elsif rate.zero?
			errors.add(:base, "This tee time can't be booked online yet. Please contact us.")
		elsif notes && notes.length > MAX_NOTES_LENGTH
			errors.add(:base, "Notes are limited to #{MAX_NOTES_LENGTH} characters.")
		end
	end

	# Only times the course actually offers that day (its business hours and tee interval).
	def on_tee_sheet?
		wanted = tee_time.strftime("%H:%M")
		course.available_tee_times(tee_time.to_date).any? { |slot| slot[:time].strftime("%H:%M") == wanted }
	end

	# Same arithmetic as GolfAddOn#total_price at quantity 1: per player, or once per booking.
	def add_on_amount(item)
		item.per_person? ? item.price * players_count : item.price
	end

	def currency(amount)
		ActionController::Base.helpers.number_to_currency(amount, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end
end
