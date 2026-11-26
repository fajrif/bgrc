# Booking limits the club sets through the environment, so they can change
# without a code change. Each reader falls back to the default when the
# variable is blank or not a positive whole number.
module BookingRules
  DEFAULTS = {
    "COURT_BOOKING_WINDOW_DAYS" => 14,
    "GOLF_BOOKING_WINDOW_DAYS"  => 14,
    "GOLF_TEE_INTERVAL_MINUTES" => 15,
    "COURT_MAX_BOOKING_HOURS"   => 4
  }.freeze

  def self.read(name)
    value = ENV[name].to_s.strip
    value.match?(/\A\d+\z/) && value.to_i.positive? ? value.to_i : DEFAULTS.fetch(name)
  end

  # Court bookings (search page and bookings#create)
  def self.court_window_days = read("COURT_BOOKING_WINDOW_DAYS")
  def self.court_max_hours   = read("COURT_MAX_BOOKING_HOURS")

  # Golf reservations (tee sheet, golf_reservations#create)
  def self.golf_window_days  = read("GOLF_BOOKING_WINDOW_DAYS")

  # Tee time spacing; when set, it overrides the golf course's own interval.
  def self.golf_tee_interval = read("GOLF_TEE_INTERVAL_MINUTES")
end
