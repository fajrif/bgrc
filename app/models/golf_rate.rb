class GolfRate < ApplicationRecord
  belongs_to :golf_course

  enum :day_type, { weekday: 0, weekend: 1 }

  validates_presence_of :holes, :price, :day_type

  def self.find_rate(golf_course, holes, date)
    date = date.is_a?(Date) ? date : date.to_date
    day_type = (date.saturday? || date.sunday?) ? :weekend : :weekday
    golf_course.golf_rates.find_by(holes: holes, day_type: day_type)&.price || 0
  end

  def label_auto
    "#{day_type.capitalize} #{holes} Holes"
  end

  def price_label
    ActionController::Base.helpers.number_to_currency(price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end
end
