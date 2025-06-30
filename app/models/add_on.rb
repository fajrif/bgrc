class AddOn < ApplicationRecord

  belongs_to :booking
  belongs_to :item

	validates_presence_of :price

	after_initialize :init_record, if: :new_record?

	def init_record
    self.price = self.item.price if self.price.zero?
	end

  def total_price
    self.price * self.quantity * self.booking.duration
  end

  def item_with_quantity
    "#{self.item.name} (#{self.quantity}x)"
  end

	def price_label
		ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0) + " / Hour"
	end

	def total_price_label
    ActionController::Base.helpers.number_to_currency(self.total_price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end
end
