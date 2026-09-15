# Loaded after configatron.rb. A mistyped CLUB_TIME_ZONE should stop the app at boot, not surface on the
# first booking (see ClubTime).
unless ActiveSupport::TimeZone[configatron.club_time_zone.to_s]
	raise ArgumentError, "CLUB_TIME_ZONE #{configatron.club_time_zone.inspect} is not a known time zone (for Bali use Asia/Makassar)"
end
