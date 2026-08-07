class Menu < ApplicationRecord
	extend Mobility
	translates :name, :short_description

	belongs_to :restaurant

	has_one_attached :image, dependent: :purge

	validates_presence_of :name, :short_description

	# Matches Facility#card_image / Amenity#card_image so shared/_category_card
	# can render any of the three without a conditional.
	def card_image
		image
	end
end
