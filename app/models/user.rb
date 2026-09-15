class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #  :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

  include OmniauthableExtension
  include EmailVerificationCode

	attr_accessor :use_v2

	has_one_attached :photo, dependent: :purge
	has_many :purchases, :dependent => :destroy
	has_many :providers, :dependent => :destroy
	has_many :bookings
	has_many :golf_reservations
	has_many :class_credit_purchases
	has_many :group_class_registrations
	has_many :food_orders

	validates_presence_of :full_name, :email, :phone, :gender
	# Both flags are persisted, so these accounts stay saveable later on (password
	# reset, profile edits) while their profile is still incomplete: admin_created
	# for walk-ins made at the counter, profile_incomplete for the short sign-up in
	# the payment modal. The full /register page sets neither.
	validates_presence_of :dob, :nationality, unless: :profile_optional?

	before_save :clear_profile_incomplete, if: :profile_incomplete?
	validates :password, presence: true, on: :create
	validates_uniqueness_of :email

	default_scope { order(created_at: :desc) }
	scope :new_users, -> { where("created_at > ?", 1.week.ago) }

  alias_attribute :name, :full_name

	def gender_label
		self.gender == 0 ? "Female" : "Male"
	end

  def name_with_email
    "ID: #{self.id} - #{self.full_name} (#{self.email})"
  end

	def age
		if self.dob
			now = ClubTime.today
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

	def current_bookings
		self.bookings.holding_or_rescheduling.order(date: :asc)
	end

	def paid_bookings
		self.bookings.where(status: Booking::PAID)
	end

	def booking_history
		self.bookings.where(status: [Booking::PAID, Booking::EXPIRED, Booking::CANCELLED])
	end

	def current_food_orders
		self.food_orders.holding
	end

	def food_order_history
		self.food_orders.where(status: [FoodOrder::PAID, FoodOrder::EXPIRED, FoodOrder::CANCELLED])
	end

	def is_profile_completed?
		!self.address.nil? && !self.phone.blank? && !self.dob.blank?
	end

	def self.to_csv(data, options = {})
	end

	def profile_optional?
		admin_created? || profile_incomplete?
	end

	private

	# The short payment-modal sign-up counts as finished once the fields it skipped are filled in.
	def clear_profile_incomplete
		self.profile_incomplete = false if dob.present? && nationality.present?
	end
end
