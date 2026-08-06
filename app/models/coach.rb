class Coach < ApplicationRecord
	extend Mobility
	translates :role, :bio

	default_scope { order(id: :asc) }

	has_one_attached :photo, dependent: :purge
	has_many :bookings
	belongs_to :sport, optional: true

	validates_presence_of :name, :email, :phone, :price
	validates_uniqueness_of :email

	# => the coaching team shown on a sport's Club Life page
	scope :for_sport, ->(sport_id) { where(sport_id: sport_id) }

	def calculate_price(duration, use_currency=true)
    sum = 0
    duration.times { sum+= self.price }

		if use_currency
			return total_price(sum)
		else
			return sum
		end
	end

	def gender_label
		self.gender == 0 ? "Female" : "Male"
	end

	def name_with_price
    "#{ self.name } (#{self.price_label})"
	end

	def price_label
		ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0) + " / Hour"
	end
end
