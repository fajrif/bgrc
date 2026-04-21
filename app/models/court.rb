class Court < ApplicationRecord
	extend Mobility
  translates :info, :instructions, :description

	default_scope { order(id: :asc) }

	has_many :bookings
	has_many :business_hours, dependent: :destroy
	has_many :costs, dependent: :destroy
	has_many :recurring_events, dependent: :destroy
  belongs_to :sport
  belongs_to :court_type

	validates_presence_of :name, :price, :location
	validates :min_duration, numericality: { less_than_or_equal_to: 6, only_integer: true }

	after_create :generate_business_hours

	def generate_business_hours
		7.times do |num|
			self.business_hours.create(day_code: num)
		end if self.business_hours.empty?
	end

	def operational_hours_label
		bh = self.business_hours
		unless bh.empty?
			weekdays = bh.select {|b| b.day_code != 0 and b.day_code != 6 }
			weekends = bh.select {|b| b.day_code == 0 or b.day_code == 6 }.reverse

			unless weekdays.empty?
				strLabel = "#{weekdays.first.day_name} – #{weekdays.last.day_name}: #{Time.parse(weekdays.first.open).strftime("%H:%M %p")} – #{Time.parse(weekdays.first.close).strftime("%H:%M %p")}"
				strLabel += "<br/>"
			end

			unless weekends.empty?
				weekends.each_with_index do |d, idx|
					strLabel += " - " if idx > 0
					strLabel += "#{d.day_name}"
				end
				strLabel += ": #{Time.parse(weekends.first.open).strftime("%H:%M %p")} – #{Time.parse(weekends.first.close).strftime("%H:%M %p")}"
			end

			return strLabel
		end
	end

	def get_min_open_time
		bh = self.business_hours
		bh.map(&:open).min
	end

	def get_max_open_time
		bh = self.business_hours
		bh.map(&:close).max
	end

	def calculate_price(start, duration, use_currency=true)
    sum = 0
		d = start.is_a?(String) ? Time.parse(start) : start
		costs = self.costs.where(day_code: d.wday)

		if costs.empty?
			duration.times { sum+= self.price }
		else
			duration.times do |i|
				dc = d + i.hour
				amount = 0.0
				costs.each do |cost|
					if dc.hour >= Time.parse(cost.start_time).hour and dc.hour <= Time.parse(cost.end_time).hour
						amount+= cost.price
					end
				end
				amount = self.price if amount.zero?
				sum+= amount
			end
		end

		if use_currency
			return total_price(sum)
		else
			return sum
		end
	end

	def name_label
    "#{self.sport.name} #{self.name} (#{self.court_type.name})"
	end

	def full_name_label
    "#{self.name_label} [#{self.price_label}]"
	end

	def is_available?
		self.status == 0
	end

	def status_label
		self.is_available? ? "Court is Available" : "This court temporary unavailable"
	end

	def name_with_price
    "#{ self.name } [#{self.price_label}]"
	end

	def price_label
		ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0) + " / Hour"
	end

	def total_price(price=nil)
		ActionController::Base.helpers.number_to_currency(price.nil? ? self.price : price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end
end
