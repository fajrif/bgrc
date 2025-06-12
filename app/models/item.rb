class Item < ApplicationRecord

	default_scope { order(id: :asc) }

	validates_presence_of :name, :price
	validates_uniqueness_of :name

	def price_label
		ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end

end
