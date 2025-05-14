class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #  :lockable, :timeoutable, :trackable and :confirmable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

  include OmniauthableExtension

	has_many :purchases, :dependent => :destroy
	has_many :providers, :dependent => :destroy
	has_many :bookings

	validates_presence_of :full_name, :email, :phone
	validates :password, presence: true, on: :create
	validates_uniqueness_of :email

	default_scope { order(created_at: :desc) }
	scope :new_users, -> { where("created_at > ?", 1.week.ago) }

	def gender_label
		self.gender == 0 ? "Female" : "Male"
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
		self.bookings.where('status = ? AND date < ?', 0, Date.today).delete_all
	end

	def current_bookings
		self.bookings.where('date >= ? AND status = ?', Date.today, 0)
	end

	def paid_bookings
		self.bookings.where(status: 1)
	end

	def is_profile_completed?
		!self.address.nil? && !self.phone.blank? && !self.dob.blank?
	end

	def self.to_csv(data, options = {})
		cols = ["ID", "Name", "Email", "Phone", "Registered At"]
		CSV.generate(options) do |csv|
			csv << cols
			data.each do |user|
				csv << [user.id, user.full_name, user.email, user.phone.to_s,user.created_at.strftime('%d-%m-%Y %H:%M')]
			end
		end
	end
end
