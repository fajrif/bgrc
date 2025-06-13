class Coach < ApplicationRecord

	default_scope { order(id: :asc) }

	has_one_attached :photo, dependent: :purge
	has_many :bookings

	validates_presence_of :name, :email, :phone, :price
	validates_uniqueness_of :email

	def gender_label
		self.gender == 0 ? "Female" : "Male"
	end

	def price_label
		ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0) + " / Hour"
	end
end
