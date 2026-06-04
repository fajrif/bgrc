class GolfBusinessHour < ApplicationRecord
  default_scope { order(day_code: :asc) }

  belongs_to :golf_course

  validates_presence_of :day_name, :day_code

  before_validation :set_day_name

  def set_day_name
    self.day_name = Date::DAYNAMES[self.day_code]
  end
end
