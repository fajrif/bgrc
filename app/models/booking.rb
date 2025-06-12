class Booking < ApplicationRecord
	default_scope { order(date: :desc) }

	belongs_to :user
	belongs_to :court
	belongs_to :coach, optional: true
	has_one :purchase, as: :productable
  has_many :add_ons

	validates_presence_of :date

	after_validation :ensure_end_date_has_value, :calculate_prices

	def ensure_end_date_has_value
		# set 1 hour if end_date empty
		self.end_date = self.date + self.duration.hour unless self.date.nil?
	end

	def calculate_prices
		self.price = self.court.calculate_price(self.date, self.duration, false) unless self.price_changed?
	end

	def is_unpaid?
		self.status.zero?
	end

	def duration_label
		"#{self.duration} hour".pluralize(self.duration)
	end

	def status_label
		self.status == 1 ? "Paid" : "Unpaid"
	end

	def price_label
		return ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

	def name
		self.try(:court).try(:name)
	end

	def paid!
		self.status = 1
		self.save!
	end

	def order_id
		self.try(:purchase).try(:order_id)
	end

	def send_email_notification!
		# s1 = true
		# s2 = true
		# begin
		# 	PurchaseMailer.with(booking: self).booking_purchase_email.deliver_now
		# rescue Exception => e
		# 	s1 = false
		# 	puts e.message
		# end
		# begin
		#  unless self.court.contact_email.blank?
		# 	PurchaseMailer.with(booking: self).new_booking_email.deliver_now
		#  else
		# 	 s2 = false
		#  end
		# rescue Exception => e
		# 	s2 = false
		# 	puts e.message
		# end
		# return (s1 or s2)
	end

	# get all bookings by day only
	# generate array of time booking based on duration
	# check the date and time
	def self.check_available_dates?(court_id, dates, duration, not_in_id=0)
		status = true
		arr_dates = []
		duration.to_i.times do |i|
			arr_dates << (DateTime::strptime(dates,"%d/%m/%Y %H:%M") + i.hour).strftime("%d/%m/%Y %H:%M")
		end
		books = Booking.where("id <> ? AND court_id = ? AND date BETWEEN ? AND ?", not_in_id, court_id, DateTime::strptime(dates,"%d/%m/%Y").beginning_of_day, DateTime::strptime(dates,"%d/%m/%Y").end_of_day)
		unless books.empty?
			arr = []
			books.each do |b|
				b.duration.times do |i|
					arr << (b.date + i.hour).strftime("%d/%m/%Y %H:%M")
				end
			end
			intersection = arr & arr_dates
			unless intersection.empty?
				status = false
			end
		end
		return status
	end

	def self.to_csv(data, options = {})
		cols = ["ID", "Order ID", "Court", "User", "Email", "Start Date", "End Date", "Duration", "Status", "Price"]
		CSV.generate(options) do |csv|
			csv << cols
			data.each do |b|
				csv << [b.id, b.order_id, b.court.name, b.user.full_name, b.user.email, b.date.strftime('%d-%m-%Y %H:%M'), b.end_date.strftime('%d-%m-%Y %H:%M'), b.duration, b.status_label, b.price_label]
			end
		end
	end
end
