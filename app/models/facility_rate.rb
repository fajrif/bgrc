class FacilityRate < ApplicationRecord
	extend Mobility
  translates :name, :access

	belongs_to :facility

	validates_presence_of :name, :price

	scope :ordered, -> { order(position: :asc, id: :asc) }

	# Same hash shape Sport#rate_cards emits, so the pricing row renders either
	# source through one card. Sport rates carry a :duration, these an :access.
	def to_rate_card
		{ name: name, time: time.presence, access: access.presence, price: price }
	end
end
