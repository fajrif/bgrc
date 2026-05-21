require "rqrcode"

class Booking < ApplicationRecord
	default_scope { order(date: :desc) }

	UNPAID = 0
	PAID = 1
	EXPIRED = 2
	CANCELLED = 3

	belongs_to :user, optional: true
	belongs_to :court
	belongs_to :coach, optional: true
	belongs_to :group_class, optional: true
	belongs_to :class_credit_purchase, optional: true
	has_one :purchase, as: :productable
  has_many :add_ons

	validates_presence_of :date, :order_id
	validates_uniqueness_of :order_id
  validates :end_date, comparison: { greater_than: :date }

	after_initialize :init_record, if: :new_record?
	before_validation :ensure_end_date_has_value, :calculate_prices

	def init_record
    self.order_id = "BOK#{SecureRandom.base58(8)}#{Time.now.to_i}".upcase if self.order_id.blank?
    self.coach_id = nil if self.coach_id.try(:zero?)
    if self.expires_at.nil?
      db_now = self.class.connection.select_value("SELECT NOW()")
      self.expires_at = db_now.to_time + 10.minutes
    end
	end

	def ensure_end_date_has_value
		# set 1 hour if end_date empty
    unless self.date.nil?
      if self.end_date.nil?
        self.end_date = self.date + self.duration.hour
      else
        self.duration = ((self.end_date - self.date) / 3600).round
      end
    end
	end

	def calculate_prices
    if self.group_class
      unless self.price_changed?
        _price = self.group_class.check_price(self.pax, false)
        self.price = _price
        self.total_price = _price
      end
    else
      self.price = self.court.calculate_price(self.date, self.duration, false) unless self.price_changed?
      self.price_coach = self.coach.calculate_price(self.duration, false) if self.coach
      total_add_ons = 0
      self.add_ons.each do |add_on|
        total_add_ons += (add_on.total_price * self.duration)
      end
      self.total_price = self.price + self.price_coach + total_add_ons
    end
	end

	def is_unpaid?
		self.status == UNPAID
	end

	def payment_window_expired?
		expired?
	end

	def within_payment_window?
		is_unpaid?
	end

	def expired?
		self.status == EXPIRED
	end

	def cancelled?
		self.status == CANCELLED
	end

	def guest?
		user_id.nil?
	end

	def time_remaining
		return 0 unless expires_at.present? && persisted?
		result = self.class.connection.select_value(
			"SELECT GREATEST(0, EXTRACT(EPOCH FROM (expires_at - NOW()))::integer) FROM bookings WHERE id = #{id}"
		)
		result.to_i
	end

	def expire!
		self.status = EXPIRED
		self.save!
		send_expiry_email if self.user.present?
	end

	def cancel!
		self.status = CANCELLED
		self.save!
	end

	def create_purchase_record!
		Purchase.create!(
			user: self.user,
			productable: self,
			token: "CASHIER-#{SecureRandom.base58(8)}",
			status_code: "200",
			status_message: "Cashier Payment",
			transaction_id: "CASHIER-#{Time.now.to_i}",
			gross_amount: self.total_price,
			payment_type: "CASHIER",
			transaction_status: "settlement"
		)
	end

	def duration_label
		"#{self.duration} hour".pluralize(self.duration)
	end

	def status_label
		return "Refunded" if refunded?
		case self.status
		when PAID then "Paid"
		when EXPIRED then "Expired"
		when CANCELLED then "Cancelled"
		else "Unpaid"
		end
	end

	def price_label
		return ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

	def price_coach_label
		return ActionController::Base.helpers.number_to_currency(self.price_coach, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

	def total_price_label
		return ActionController::Base.helpers.number_to_currency(self.total_price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

	def name
		self.try(:court).try(:name)
	end

	def order_name_label
    "#{self.try(:user).try(:name)} - #{self.order_id}"
	end

	def paid!
		self.status = PAID
		self.save!
	end

	def send_email_notification!
		s1 = true
		s2 = true
		begin
			PurchaseMailer.with(booking: self).booking_purchase_email.deliver_now
		rescue Exception => e
			s1 = false
			puts e.message
		end
		begin
			PurchaseMailer.with(booking: self).new_booking_email.deliver_now
		rescue Exception => e
			s2 = false
			puts e.message
		end
		return (s1 or s2)
	end

	# get all bookings by day only
	# generate array of time booking based on duration
	# check the date and time
	def self.check_available_dates?(court_id, dates, duration, not_in_id=0)
		status = true
		parsed = DateTime::strptime(dates, "%d/%m/%Y %H:%M")
		arr_dates = duration.to_i.times.map { |i| (parsed + i.hour).strftime("%d/%m/%Y %H:%M") }

		books = Booking.where("id <> ? AND court_id = ? AND status NOT IN (?, ?) AND date BETWEEN ? AND ?",
		                      not_in_id, court_id, EXPIRED, CANCELLED,
		                      parsed.beginning_of_day, parsed.end_of_day)
		unless books.empty?
			arr = []
			books.each do |b|
				b.duration.times { |i| arr << (b.date + i.hour).strftime("%d/%m/%Y %H:%M") }
			end
			status = false unless (arr & arr_dates).empty?
		end

		if status
			# Check RecurringEvents (court-blocking events/ceremonies)
			blocks = RecurringEvent.joins(:recurring_event_courts)
			          .where(active: true, recurring_event_courts: { court_id: court_id })
			          .where("(specific_date IS NULL AND day_of_week = ?) OR (specific_date IS NOT NULL AND ? BETWEEN specific_date AND COALESCE(end_date, specific_date))", parsed.wday, parsed.to_date)
			# Also check GroupClassSchedules (prescheduled group class slots)
			class_schedules = GroupClassSchedule.where(court_id: court_id, day_of_week: parsed.wday)
			(blocks.to_a + class_schedules.to_a).each do |re|
				re_start = parsed.strftime("%Y-%m-%d") + "T" + re.start_time
				re_end   = parsed.strftime("%Y-%m-%d") + "T" + re.end_time
				re_start_dt = DateTime.parse(re_start)
				re_end_dt   = DateTime.parse(re_end)
				re_slots = []
				slot = re_start_dt
				while slot < re_end_dt
					re_slots << slot.strftime("%d/%m/%Y %H:%M")
					slot += 1.hour
				end
				unless (re_slots & arr_dates).empty?
					status = false
					break
				end
			end
		end

		return status
	end

	def self.expire_stale_bookings!
		Booking.unscoped.where(status: UNPAID).where("expires_at < NOW()").find_each do |booking|
			booking.expire!
		end
	end

  def get_court_type
    case self.court_type
    when 0
      "Court Only"
    when 1
      "Court + Coach"
    end
  end

  def get_class_type
    case self.class_type
    when 0
      "2 People, Semi Private"
    when 1
      "4 People, Semi Private"
    end
  end

  def qrcode
    qrcode = RQRCode::QRCode.new(self.order_id)
    # NOTE: showing with default options specified explicitly
    svg = qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 8,
      standalone: true,
      use_path: true
    )
  end

  private

  def send_expiry_email
    begin
      PurchaseMailer.with(booking: self).booking_expired_email.deliver_now
    rescue Exception => e
      puts e.message
    end
  end

end
