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

  def available_tee_times(date)
    date = date.is_a?(Date) ? date : Date.parse(date.to_s)
    day_code = date.wday
    bh = self.golf_business_hours.find_by(day_code: day_code)
    return [] if bh.nil? || bh.closed?

    open_time  = Time.parse("#{date} #{bh.open}")
    close_time = Time.parse("#{date} #{bh.close}")

    now = Time.current

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
      if date == Date.current && slot <= now
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
