class Restaurant < ApplicationRecord
	extend Mobility
	translates :slug, :name, :short_description, :description, :banner_description, :description1, :description2
	# Optional labelled lines under the intro copy. Not validated — most venues
	# leave them blank and the block is skipped entirely when they are.
	translates :concept, :operating_hours, :location_note

	extend FriendlyId
	friendly_id :name, use: :mobility

	has_one_attached :banner,        dependent: :purge
	has_one_attached :middle_banner, dependent: :purge
	has_one_attached :image,         dependent: :purge
	has_many_attached :images,       dependent: :purge

	has_many :menus, -> { order(position: :asc, id: :asc) }, dependent: :destroy

	validates_presence_of :name, :short_description, :description, :banner_description, :description1, :description2
	validates_uniqueness_of :name

	def should_generate_new_friendly_id?
		name_changed?
	end

	def en_name
		Mobility.with_locale(:en) { name }
	end
end
