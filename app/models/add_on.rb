class AddOn < ApplicationRecord

  belongs_to :booking
  belongs_to :item

	validates_presence_of :price

	def price_label
		ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end

	def total_price
    ActionController::Base.helpers.number_to_currency(self.price * self.quantity, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end
end
