# The club's clock (CLUB_TIME_ZONE, default Asia/Makassar). Court slots, tee times and class sessions are
# stored as club wall-clock times labelled UTC, with no zone conversion. So "what day is it" and "has this
# slot started" must be asked here — never of Date.today / Time.now (the server's own zone) or of
# Date.current / Time.current (UTC). Absolute moments such as created_at, paid_at and payment deadlines
# stay on Time.current, and are shown to people with ClubTime.local.
module ClubTime
	module_function

	def zone
		ActiveSupport::TimeZone[configatron.club_time_zone.to_s]
	end

	def today
		zone.today
	end

	# The club's wall-clock time now, labelled UTC like stored booking times, so the two compare directly.
	def now
		wall = zone.now
		Time.utc(wall.year, wall.month, wall.day, wall.hour, wall.min, wall.sec)
	end

	# A club wall-clock time on `date` at "HH:MM" (business hours, class schedules).
	def wall_clock(date, hh_mm)
		hour, minute = hh_mm.to_s.split(":").map(&:to_i)
		Time.utc(date.year, date.month, date.day, hour || 0, minute || 0)
	end

	# An absolute moment (created_at, paid_at, expires_at) in the club's zone, for display.
	def local(instant)
		instant&.in_time_zone(zone)
	end

	# Read by the frontend's club clock (app/frontend/lib/clubClock.ts) through the layout's club-now meta tag.
	def now_iso
		now.strftime("%Y-%m-%dT%H:%M:%S")
	end
end
