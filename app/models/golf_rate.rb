class GolfRate < ApplicationRecord
  belongs_to :golf_course

  enum :day_type, { weekday: 0, weekend: 1 }

  validates_presence_of :holes, :price, :day_type
  validates :end_time, presence: true, if: -> { start_time.present? }
  validates :start_time, presence: true, if: -> { end_time.present? }
  validate :end_time_after_start_time

  def self.find_rate(golf_course, holes, date)
    tee_time_datetime = date.is_a?(Date) ? date.to_time : date
    day_type = (tee_time_datetime.saturday? || tee_time_datetime.sunday?) ? :weekend : :weekday
    time_str = tee_time_datetime.strftime("%H:%M")

    rates       = golf_course.golf_rates.where(holes: holes, day_type: day_type)
    window_rate = rates.detect { |r| r.covers?(time_str) }
    base_rate   = rates.detect { |r| !r.windowed? }

    (window_rate || base_rate)&.price || 0
  end

  def windowed?
    start_time.present? && end_time.present?
  end

  def covers?(time_str)
    windowed? && time_str >= start_time && time_str < end_time
  end

  def label_auto
    windowed? ? "#{day_type.capitalize} #{holes} Holes (#{start_time}-#{end_time})" : "#{day_type.capitalize} #{holes} Holes"
  end

  def price_label
    ActionController::Base.helpers.number_to_currency(price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

  private

  def end_time_after_start_time
    return unless start_time.present? && end_time.present?
    errors.add(:end_time, "must be after start time") unless end_time > start_time
  end
end
