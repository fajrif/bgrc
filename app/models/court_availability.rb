# What the public booking calendar shows for one court over a run of days: when the court is open,
# and which hours are taken — live holds and paid bookings, closures and events, and group-class
# slots. Times are wall-clock strings ("YYYY-MM-DD HH:MM", no time zone), the convention the
# calendar and Booking#date have always shared.
class CourtAvailability
	def initialize(court, from:, to:)
		@court = court
		@days = (from...to).to_a
	end

	def as_json(*)
		{
			court_id: court.id,
			min_duration: court.min_duration,
			slot_min_time: court.get_min_open_time || "06:00",
			slot_max_time: court.get_max_open_time || "22:00",
			business_hours: court.business_hours.map { |bh| { daysOfWeek: [bh.day_code], startTime: bh.open, endTime: bh.close } },
			events: booking_events + blocked_events + recurring_event_events + class_schedule_events,
		}
	end

	private

	attr_reader :court, :days

	# `holding`: an unpaid hold shows as Booked until its payment deadline, then frees up on its own.
	def booking_events
		range = days.first.beginning_of_day...(days.last + 1).beginning_of_day
		court.bookings.holding.where(date: range).map do |booking|
			{ title: "Booked", editable: false, className: "booking-block", start: wall_clock(booking.date), end: wall_clock(booking.end_date) }
		end
	end

	def active_recurring_events
		@active_recurring_events ||= court.recurring_events.where(active: true).to_a
	end

	# Hidden one-off events close the court outright; anything else on those hours is not shown.
	def blocked_slots
		@blocked_slots ||= active_recurring_events.select { |event| event.hide? && event.one_time? }.flat_map do |event|
			days.select { |day| (event.specific_date..event.effective_end_date).cover?(day) }
			    .map { |day| { date: day, start: event.start_time, end: event.end_time } }
		end
	end

	def blocked_events
		blocked_slots.map do |slot|
			{ title: "", editable: false, className: "recurring-event-block",
			  start: "#{slot[:date]} #{slot[:start]}", end: "#{slot[:date]} #{slot[:end]}" }
		end
	end

	def recurring_event_events
		active_recurring_events.reject { |event| event.hide? && event.one_time? }.flat_map do |event|
			base = if event.hide?
				{ title: "", editable: false, className: "recurring-event-block" }
			else
				{ title: event.title, editable: false, className: "recurring-event-visible",
				  extendedProps: { signUpUrl: routes.recurring_event_path(id: event.id) } }
			end

			days.select { |day| event.one_time? ? (event.specific_date..event.effective_end_date).cover?(day) : day.wday == event.day_of_week }
			    .reject { |day| overlaps_blocked_slot?(day, event.start_time, event.end_time) }
			    .map { |day| base.merge(start: "#{day} #{event.start_time}", end: "#{day} #{event.end_time}") }
		end
	end

	def class_schedule_events
		court.group_class_schedules.includes(:group_class).flat_map do |schedule|
			days.select { |day| day.wday == schedule.day_of_week }
			    .reject { |day| overlaps_blocked_slot?(day, schedule.start_time, schedule.end_time) }
			    .map do |day|
				{ title: schedule.group_class.name, editable: false, className: "class-schedule-block",
				  start: "#{day} #{schedule.start_time}", end: "#{day} #{schedule.end_time}",
				  extendedProps: { classUrl: routes.group_class_path(id: schedule.group_class.id) } }
			end
		end
	end

	def overlaps_blocked_slot?(day, starts_at, ends_at)
		blocked_slots.any? do |slot|
			slot[:date] == day && Time.parse(slot[:start]) < Time.parse(ends_at) && Time.parse(slot[:end]) > Time.parse(starts_at)
		end
	end

	def wall_clock(time)
		time.strftime("%Y-%m-%d %H:%M")
	end

	def routes
		Rails.application.routes.url_helpers
	end
end
