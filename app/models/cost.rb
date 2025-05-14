class Cost < ApplicationRecord

	default_scope { order(day_code: :asc) }

	belongs_to :court

	validates_presence_of :day_name, :day_code, :start_time, :end_time, :price

	before_validation :set_day_name

	def set_day_name
		self.day_name = Date::DAYNAMES[self.day_code]
	end

	def price_label
		ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0) + " / Hour"
	end
end
