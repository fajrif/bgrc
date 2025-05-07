class Sport < ApplicationRecord
	extend Mobility
  translates :short_description, :description

	extend FriendlyId
  friendly_id :name, use: :slugged

	has_one_attached :image, dependent: :purge
	has_many_attached :images, dependent: :purge
  has_many :events
  has_many :promos

	validates_presence_of :name, :short_description, :description
	validates_uniqueness_of :name

	def should_generate_new_friendly_id?
		self.name_changed?
	end
end
