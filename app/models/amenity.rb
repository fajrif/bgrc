class Amenity < ApplicationRecord
	extend Mobility
  translates :name, :short_description

	belongs_to :facility

	has_one_attached :image, dependent: :purge

	validates_presence_of :name, :short_description

	# Matches Facility#card_image's interface so shared/_category_card can
	# render either kind of record without a conditional.
	def card_image
		image
	end
end
