class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #  :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable, # :confirmable,
         :recoverable, :rememberable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

  include OmniauthableExtension

	attr_accessor :use_v2

	has_one_attached :photo, dependent: :purge
	has_many :purchases, :dependent => :destroy
	has_many :providers, :dependent => :destroy
	has_many :bookings
	has_many :class_credit_purchases
	has_many :group_class_registrations

	validates_presence_of :full_name, :email, :phone, :dob, :gender, :nationality
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
		self.bookings
	end

	def paid_bookings
		self.bookings.where(status: Booking::PAID)
	end

	def booking_history
		self.bookings.where(status: [Booking::PAID, Booking::EXPIRED, Booking::CANCELLED])
	end

	def is_profile_completed?
		!self.address.nil? && !self.phone.blank? && !self.dob.blank?
	end

	def self.to_csv(data, options = {})
	end
end
