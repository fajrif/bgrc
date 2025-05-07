class Facility < ApplicationRecord
	extend Mobility
  translates :slug, :name, :short_description, :description

	extend FriendlyId
  friendly_id :name, use: :slugged

	has_one_attached :image, dependent: :purge
	has_many_attached :images, dependent: :purge

	validates_presence_of :name, :short_description, :description
	validates_uniqueness_of :name

	def should_generate_new_friendly_id?
		self.name_changed?
	end
end
