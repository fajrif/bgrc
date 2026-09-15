require "rqrcode"

class Booking < ApplicationRecord
	default_scope { order(date: :desc) }

	UNPAID = 0
	PAID = 1
	EXPIRED = 2
	CANCELLED = 3
	# Paid after its hold lapsed, by which time someone else had taken the slot. BBCC does not
	# refund, so the customer chooses a new time at the price already paid.
	NEEDS_RESCHEDULE = 4

	# `court_type`: what the booking includes. The column defaults to COURT_ONLY, and `pax` defaults to 4.
	COURT_ONLY = 0
	WITH_COACH = 1
	COURT_TYPE_LABELS = { COURT_ONLY => "Court Only", WITH_COACH => "Court + Coach" }.freeze

	include PaymentWindow

	# Set when a paid booking is moved or confirmed, so calculate_prices leaves the paid amount alone.
	attr_accessor :keep_paid_price

	# What "My Bookings" lists as current: live holds, paid bookings, and late payments awaiting a new time.
	scope :holding_or_rescheduling, -> { holding.or(where(status: NEEDS_RESCHEDULE)) }

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
    return if keep_paid_price

    if self.group_class
      unless self.price_changed?
        _price = self.group_class.check_price(self.pax, false)
        self.price = _price
        self.total_price = _price
      end
    else
      self.price = self.court.calculate_price(self.date, self.duration, false) unless self.price_changed?
      self.price_coach = self.coach.calculate_price(self.duration, false) if self.coach
      # AddOn#total_price is already price x quantity x duration (add-on prices
      # are per-hour — see AddOn#price_label). Multiplying by duration again
      # here billed add-ons at duration squared: a 2-hour booking with a
      # Rp 20.000/hour racket charged Rp 80.000 instead of Rp 40.000, while
      # every screen and email showed the correct Rp 40.000.
      total_add_ons = 0
      self.add_ons.each do |add_on|
        total_add_ons += add_on.total_price
      end
      self.total_price = self.price + self.price_coach + total_add_ons
    end
	end

	def is_unpaid?
		self.status == UNPAID
	end

	def expired?
		self.status == EXPIRED
	end

	def cancelled?
		self.status == CANCELLED
	end

	def needs_reschedule?
		self.status == NEEDS_RESCHEDULE
	end

	def guest?
		user_id.nil?
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
			transaction_status: "settlement",
			# Counter payment: no gateway was involved, so reconciliation must skip it.
			payment_gateway: PaymentGateways::CASHIER,
			paid_at: Time.current
		)
	end

	def cashier_booking?
		purchase&.payment_type == "CASHIER"
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
		when NEEDS_RESCHEDULE then "Needs reschedule"
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

		# `holding`, not "anything but expired/cancelled": an unpaid hold stops blocking at its
		# deadline even before ExpirePaymentJob has marked it expired.
		books = Booking.holding.where("bookings.id <> ? AND bookings.court_id = ? AND bookings.date BETWEEN ? AND ?",
		                      not_in_id, court_id,
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

	# For a payment that landed after the hold lapsed: is this booking's slot still free?
	def slot_still_available?
		self.class.check_available_dates?(court_id, date.strftime("%d/%m/%Y %H:%M"), duration, id)
	end

  def get_court_type
    COURT_TYPE_LABELS[self.court_type]
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
