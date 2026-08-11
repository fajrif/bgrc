class EventType < ApplicationRecord
	include OrderedImages

	extend Mobility
  translates :slug, :name, :short_description, :description

	extend FriendlyId
	friendly_id :name, use: :mobility

	has_one_attached :image, dependent: :purge
	has_one_attached :banner, dependent: :purge
	has_many_attached :images, dependent: :purge

	validates_presence_of :name, :short_description

	scope :ordered, -> { order(position: :asc, id: :asc) }

	def should_generate_new_friendly_id?
		self.name_changed?
	end

	# The English name is the stable key the seed and admin views key off, so it
	# does not shift when the visitor switches to Indonesian.
	def en_name
		Mobility.with_locale(:en) { name }
	end

	def gallery_images
		ordered_images
	end
end
