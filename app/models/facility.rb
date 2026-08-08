class Facility < ApplicationRecord
	include OrderedImages

	extend Mobility
  translates :slug, :name, :short_description, :description, :cta_label, :facilities_intro,
						 :treatments_title

	extend FriendlyId
  friendly_id :name, use: :mobility

	belongs_to :parent, class_name: "Facility", optional: true
	has_many :children, -> { order(position: :asc, id: :asc) },
					 class_name: "Facility", foreign_key: :parent_id, dependent: :nullify
	belongs_to :sport, optional: true

	# Card-only content with no page of its own (venue listings, restaurants, ...).
	has_many :amenities, -> { order(position: :asc, id: :asc) }, dependent: :destroy

	# Free-form info blocks in the intro column ("Operating Hours", "Capacity",
	# "Pool Specifications", ...) — a section shows as many or as few as it needs.
	has_many :facility_details, -> { order(position: :asc, id: :asc) }, dependent: :destroy

	# Membership-style pricing for a section with no bookable sport behind it.
	has_many :facility_rates, -> { order(position: :asc, id: :asc) }, dependent: :destroy

	# Bookable treatments and services — the Spa + Wellness equivalent of a
	# sport's class programme.
	has_many :treatments, -> { order(position: :asc, id: :asc) }, dependent: :destroy

	has_one_attached :image, dependent: :purge
	has_one_attached :banner, dependent: :purge
	has_one_attached :middle_banner, dependent: :purge
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

	# Rates entered against the section itself win — they describe memberships and
	# passes, which no court schedule can express. Sections tied to a sport fall
	# back to that sport's real court pricing.
	def rate_cards
		rates = facility_rates.to_a
		return rates.map(&:to_rate_card) if rates.any?
		sport&.rate_cards || []
	end

	# The pricing row fronts a sport icon, which only reads right on the cards
	# that actually came from a sport's courts.
	def rate_cards_from_sport?
		sport.present? && facility_rates.none?
	end

	# Linked sports already carry six real gallery photos each; use them
	# instead of asking the admin to upload the same images twice.
	def gallery_images
		sport&.images&.attached? ? sport.ordered_images : ordered_images
	end

	# Whether this page's gallery is its own uploads or the linked sport's.
	def gallery_inherited?
		sport&.images&.attached? || false
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
