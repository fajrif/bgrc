class GroupClassSchedule < ApplicationRecord
  belongs_to :group_class
  belongs_to :court

  validates :court_id, :day_of_week, :start_time, :end_time, presence: true
  validates :day_of_week, inclusion: { in: 0..6 }

  DAY_NAMES = {
    0 => "Sunday", 1 => "Monday", 2 => "Tuesday", 3 => "Wednesday",
    4 => "Thursday", 5 => "Friday", 6 => "Saturday"
  }.freeze

  def self.days_for_select
    DAY_NAMES.map { |k, v| [v, k] }
  end

  def day_name
    DAY_NAMES[day_of_week]
  end
end
