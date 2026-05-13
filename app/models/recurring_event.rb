class RecurringEvent < ApplicationRecord
  belongs_to :court
  has_many :event_rsvps, dependent: :destroy
  has_one_attached :image, dependent: :purge

  validates_presence_of :title, :court_id, :start_time, :end_time
  validates :day_of_week, inclusion: { in: 0..6 }, allow_nil: true
  validate :requires_day_or_date

  scope :active, -> { where(active: true) }

  DAY_NAMES = {
    0 => "Sunday", 1 => "Monday", 2 => "Tuesday", 3 => "Wednesday",
    4 => "Thursday", 5 => "Friday", 6 => "Saturday"
  }.freeze

  def day_name
    DAY_NAMES[day_of_week]
  end

  def self.days_for_select
    DAY_NAMES.map { |k, v| [v, k] }
  end

  def recurring?
    specific_date.nil?
  end

  def one_time?
    specific_date.present?
  end

  def rsvp_open?
    capacity == 0 || event_rsvps.count < capacity
  end

  private

  def requires_day_or_date
    if specific_date.blank? && day_of_week.nil?
      errors.add(:base, "Either a specific date or a day of week is required")
    end
  end
end