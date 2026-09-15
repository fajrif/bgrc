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

  AVAILABLE   = 0
  UNAVAILABLE = 1

  # Admins can run several courses (seasonal ones with their own rates) and drag them into order on the
  # admin index. The first active course is the one customers book.
  scope :active, -> { where(status: AVAILABLE) }
  scope :ordered, -> { order(:position, :id) }

  before_create :append_to_order
  after_create :generate_business_hours

  def self.current
    active.ordered.first
  end

  def generate_business_hours
    7.times { |num| self.golf_business_hours.create(day_code: num) } if self.golf_business_hours.empty?
  end

  # Every tee time on `date` with the places left. Times are club wall-clock values, like tee_time
  # itself, so the sheet is the same whatever zone the server runs in.
  def available_tee_times(date)
    date = date.is_a?(Date) ? date : Date.parse(date.to_s)
    bh = self.golf_business_hours.find_by(day_code: date.wday)
    return [] if bh.nil? || bh.closed?

    open_time  = ClubTime.wall_clock(date, bh.open)
    close_time = ClubTime.wall_clock(date, bh.close)
    now = ClubTime.now

    slots = []
    t = open_time
    while t < close_time
      slots << t
      t += self.interval_minutes.minutes
    end

    booked_counts = self.golf_reservations
                        .holding
                        .where("tee_time::date = ?", date)
                        .group(:tee_time)
                        .sum(:players_count)
                        .transform_keys { |tt| tt.utc.strftime("%H:%M") }

    slots.map do |slot|
      if slot <= now
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
    is_available? ? "Active" : "Inactive"
  end

  private

  def append_to_order
    self.position = (GolfCourse.maximum(:position) || 0) + 1 if position.to_i.zero?
  end
end
