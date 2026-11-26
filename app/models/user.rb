class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #  :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

  include OmniauthableExtension

	attr_accessor :use_v2

	has_one_attached :photo, dependent: :purge
	has_many :purchases, :dependent => :destroy
	has_many :providers, :dependent => :destroy
	has_many :bookings
	has_many :golf_reservations
	has_many :class_credit_purchases
	has_many :group_class_registrations
	has_many :food_orders

	# Sign-up asks for name, email, password and phone only. Date of birth,
	# gender and nationality are optional and can be added on the account page.
	validates_presence_of :full_name, :email, :phone

	# Country codes offered on the phone field. Each code is the prefix stored in
	# front of the local number, e.g. "+62 81234567".
	PHONE_COUNTRY_CODES = {
		"Indonesia (+62)" => "+62", "Australia (+61)" => "+61", "Singapore (+65)" => "+65",
		"Malaysia (+60)" => "+60", "Thailand (+66)" => "+66", "Philippines (+63)" => "+63",
		"Vietnam (+84)" => "+84", "Hong Kong (+852)" => "+852", "Taiwan (+886)" => "+886",
		"China (+86)" => "+86", "Japan (+81)" => "+81", "South Korea (+82)" => "+82",
		"India (+91)" => "+91", "United Arab Emirates (+971)" => "+971",
		"United Kingdom (+44)" => "+44", "Netherlands (+31)" => "+31", "Germany (+49)" => "+49",
		"France (+33)" => "+33", "Russia (+7)" => "+7", "United States / Canada (+1)" => "+1"
	}.freeze
	DEFAULT_PHONE_CODE = "+62"

	# "+62" + "0812-3456" => "+62 812 3456". A leading 0 (national trunk prefix) is dropped.
	# Returns "" when the local number is not 6 to 15 digits, so presence validation fails.
	def self.join_phone(code, local)
		digits = local.to_s.gsub(/[\s\-()]/, "")
		digits = digits.sub(/\A0/, "") if digits.start_with?("0")
		return "" unless digits.match?(/\A\d{6,15}\z/)
		"#{code.presence || DEFAULT_PHONE_CODE} #{digits}"
	end

	# Inverse of join_phone for the form: ["+62", "81234567"]. Numbers saved before
	# country codes existed have no known prefix and come back as the default code.
	def self.split_phone(phone)
		value = phone.to_s.strip
		code = PHONE_COUNTRY_CODES.values.sort_by { |c| -c.length }.find { |c| value.start_with?(c) }
		return [code, value.delete_prefix(code).strip] if code
		[DEFAULT_PHONE_CODE, value]
	end

	# admin_created is a persisted column, so walk-in accounts created at the
	# counter stay saveable later on (password reset, profile edits) even while
	# their profile is still incomplete. Public self-registration never sets it.
	validates :password, presence: true, on: :create
	validates_uniqueness_of :email

	default_scope { order(created_at: :desc) }
	scope :new_users, -> { where("created_at > ?", 1.week.ago) }

  alias_attribute :name, :full_name

	def gender_label
		case self.gender
		when 0 then "Female"
		when 1 then "Male"
		end
	end

  def name_with_email
    "ID: #{self.id} - #{self.full_name} (#{self.email})"
  end

	def age
		if self.dob
			now = Time.now.utc.to_date
			now.year - self.dob.year - ((now.month > self.dob.month || (now.month == self.dob.month && now.day >= self.dob.day)) ? 0 : 1)
		end
	end

  def self.authenticate(email, password)
    user = User.find_for_authentication(:email => email)
    user.valid_password?(password) ? user : nil
  end

  def active_for_authentication?
    super
  end

	def remove_all_unpaid_bookings
		Booking.expire_stale_bookings!
	end

	def current_bookings
		self.bookings.where(status: [Booking::UNPAID, Booking::PAID]).order(date: :asc)
	end

	def paid_bookings
		self.bookings.where(status: Booking::PAID)
	end

	def booking_history
		self.bookings.where(status: [Booking::PAID, Booking::EXPIRED, Booking::CANCELLED])
	end

	def current_food_orders
		self.food_orders.where(status: [FoodOrder::UNPAID, FoodOrder::PAID])
	end

	def food_order_history
		self.food_orders.where(status: [FoodOrder::PAID, FoodOrder::EXPIRED, FoodOrder::CANCELLED])
	end

	def is_profile_completed?
		!self.address.nil? && !self.phone.blank? && !self.dob.blank?
	end

	def self.to_csv(data, options = {})
	end
end
