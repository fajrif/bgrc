class GroupClass < ApplicationRecord

	default_scope { order(id: :asc) }

	validates_presence_of :name, :price
	validates_uniqueness_of :name

	def duration_label
		"#{self.min_duration} hour".pluralize(self.min_duration)
	end

	def status_label
		self.status == 1 ? "Available" : "Unavailable"
	end

	def price_label
		ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end

	def price_pax_label
		ActionController::Base.helpers.number_to_currency(self.price_pax, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0) + " / Pax"
	end
end
