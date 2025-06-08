class Sport < ApplicationRecord
	extend Mobility
  translates :short_description, :description

	extend FriendlyId
  friendly_id :name, use: :slugged

	default_scope { order(id: :asc) }

	has_one_attached :image, dependent: :purge
	has_many_attached :images, dependent: :purge
  has_many :events
  has_many :promos
  has_many :courts

	validates_presence_of :name, :short_description, :description
	validates_uniqueness_of :name

	def should_generate_new_friendly_id?
		self.name_changed?
	end
end
