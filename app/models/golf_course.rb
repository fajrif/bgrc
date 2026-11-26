class GolfCourse < ApplicationRecord
  extend Mobility
  translates :description

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :golf_business_hours, dependent: :destroy
  has_many :golf_rates, dependent: :destroy
  has_many :golf_items, dependent: :destroy
  has_many :golf_reservations, dependent: :destroy
  has_one_attached :image

  validates_presence_of :name

  after_create :generate_business_hours

  AVAILABLE   = 0
  UNAVAILABLE = 1

  def generate_business_hours
    7.times { |num| self.golf_business_hours.create(day_code: num) } if self.golf_business_hours.empty?
  end

  # Tee times are club wall-clock times, so "now" and "today" are the club's, whatever
  # zone the server runs in.
  def self.club_now
    ActiveSupport::TimeZone[ENV.fetch("CLUB_TIME_ZONE", "Asia/Makassar")].now
  end

  def self.club_today
    club_now.to_date
  end

  # BookingRules.golf_tee_interval (GOLF_TEE_INTERVAL_MINUTES) overrides the course's own
  # setting when it is set; otherwise the value saved on the course is used.
  def interval_minutes
    BookingRules.golf_tee_interval || super
  end

  def available_tee_times(date)
    date = date.is_a?(Date) ? date : Date.parse(date.to_s)
    day_code = date.wday
    bh = self.golf_business_hours.find_by(day_code: day_code)
    return [] if bh.nil? || bh.closed?

    open_time  = Time.parse("#{date} #{bh.open}")
    close_time = Time.parse("#{date} #{bh.close}")

    club_now = self.class.club_now.strftime("%Y-%m-%d %H:%M")

    slots = []
    t = open_time
    while t < close_time
      slots << t
      t += self.interval_minutes.minutes
    end

    booked_counts = self.golf_reservations
                        .where(status: [GolfReservation::UNPAID, GolfReservation::PAID])
                        .where("tee_time::date = ?", date)
                        .group(:tee_time)
                        .sum(:players_count)
                        .transform_keys { |tt| tt.in_time_zone.strftime("%H:%M") }

    slots.map do |slot|
      if slot.strftime("%Y-%m-%d %H:%M") <= club_now
        { time: slot, available: false, past: true, remaining: 0 }
      else
        booked = booked_counts[slot.strftime("%H:%M")] || 0
        remaining = [self.max_players - booked, 0].max
        { time: slot, available: remaining > 0, remaining: remaining, past: false }
      end
    end
  end

  def holes_list
    holes_available.to_s.split(",").map(&:strip).map(&:to_i)
  end

  def is_available?
    self.status == AVAILABLE
  end

  def status_label
    is_available? ? "Available" : "Unavailable"
  end
end
