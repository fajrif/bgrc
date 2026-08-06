class Facility < ApplicationRecord
	extend Mobility
  translates :slug, :name, :short_description, :description, :cta_label

	extend FriendlyId
  friendly_id :name, use: :mobility

	belongs_to :parent, class_name: "Facility", optional: true
	has_many :children, -> { order(position: :asc, id: :asc) },
					 class_name: "Facility", foreign_key: :parent_id, dependent: :nullify
	belongs_to :sport, optional: true

	has_one_attached :image, dependent: :purge
	has_many_attached :images, dependent: :purge

	validates_presence_of :name, :short_description, :description
	validates_uniqueness_of :name

	# => Club Life: the five top-level sections, in display order.
	scope :club_life_roots, -> { where(club_life: true).order(position: :asc, id: :asc) }

	def should_generate_new_friendly_id?
		self.name_changed?
	end

	# A facility belongs to the Club Life tree when it is a section itself
	# or a child of one. Plain amenities (Restaurant, Pro Shop, ...) are neither.
	def in_club_life?
		club_life? || parent&.club_life? || false
	end

	def club_life_root
		club_life? ? self : parent
	end

	# The English name is the stable key the Club Life page sections key off,
	# so the layout does not change when the visitor switches to Indonesian.
	def en_name
		Mobility.with_locale(:en) { name }
	end

	# Linked sports already carry six real gallery photos each; use them
	# instead of asking the admin to upload the same images twice.
	def gallery_images
		sport&.images&.attached? ? sport.images : images
	end

	# The photo a card fronts. Falls through to the linked sport so a node that
	# has never had an image uploaded still shows its own sport rather than a
	# shared placeholder.
	def card_image
		return image if image.attached?
		return sport.image if sport&.image&.attached?
		sport&.images&.first
	end
end
