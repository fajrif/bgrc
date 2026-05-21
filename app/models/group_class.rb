class GroupClass < ApplicationRecord

	CATEGORIES = {
		"Private Lesson" => "private_lesson",
		"Group Class"    => "group_class",
		"Social Class"   => "social_class"
	}.freeze

	default_scope { order(id: :asc) }

	validates_presence_of :name, :price
	validates_uniqueness_of :name

  belongs_to :sport, optional: true
  has_many :bookings
  has_many :class_credit_purchases
  has_many :group_class_registrations
  has_many :group_class_schedules, dependent: :destroy
  has_many :group_class_packs, dependent: :destroy
  accepts_nested_attributes_for :group_class_schedules, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :group_class_packs, allow_destroy: true, reject_if: :all_blank

  scope :by_category, ->(cat) { where(category: cat) }
  scope :available, -> { where(status: 1) }
  scope :prescheduled, -> { where(is_prescheduled: true) }

  def pax_managed?
    !is_prescheduled?
  end

  def validity_label
    months = credit_validity_months || configatron.credit_validity_months || 2
    "#{months} #{months == 1 ? 'month' : 'months'}"
  end

  def category_label
    CATEGORIES.key(category) || category.to_s.humanize
  end

  def pack_sessions_range
    (min_pack_sessions..max_pack_sessions)
  end

  def slots_remaining_for(session_date)
    booked = bookings.where("date BETWEEN ? AND ?",
                            session_date.beginning_of_day,
                            session_date.end_of_day)
                     .where.not(status: [Booking::EXPIRED, Booking::CANCELLED])
                     .sum(:pax)
    registered = group_class_registrations.where(session_date: session_date.beginning_of_day..session_date.end_of_day)
                                          .active
                                          .sum(:pax)
    [max_pax - booked - registered, 0].max
  end

	def name_label
    if self.has_additional_pax?
      "#{self.name} (#{self.duration_label})"
    else
      self.name
    end
	end

	def name_with_pax(pax)
    if self.has_additional_pax?
      "#{self.name} (#{pax} Pax)"
    else
      "#{self.name}"
    end
	end

	def duration_label
    "#{self.min_duration} hour".titleize.pluralize(self.min_duration)
	end

	def status_label
		self.status == 1 ? "Available" : "Unavailable"
	end

	def has_additional_pax?
		self.price_pax > 0
	end

	def check_price(pax=nil, currency_label=true)
    _price = self.price
    unless pax.nil?
      if self.has_additional_pax? && pax.to_i > self.min_pax
        _price = self.price + (self.price_pax * (pax.to_i - self.min_pax))
      end
    end
    currency_label ? label_price(_price) : _price
	end

	def price_label
		label_price(self.price)
	end

	def price_pax_label
		label_price(self.price_pax) + " / Pax"
	end

  def upcoming_sessions(days_ahead: 14)
    sessions = []
    recurring = group_class_schedules.first
    return sessions unless recurring
    today = Date.today
    (0..days_ahead - 1).each do |offset|
      day = today + offset
      next unless day.wday == recurring.day_of_week
      session_start = DateTime.parse("#{day} #{recurring.start_time}")
      next if session_start < Time.current
      sessions << {
        date: day,
        start_time: recurring.start_time,
        end_time: recurring.end_time,
        date_label: day.strftime("%A, %d %b %Y"),
        datetime_str: day.strftime("%d/%m/%Y") + " " + recurring.start_time,
        slots_remaining: slots_remaining_for(day)
      }
    end
    sessions
  end

  protected

  def label_price(_price)
		ActionController::Base.helpers.number_to_currency(_price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end
end
