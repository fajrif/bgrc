class Package < ApplicationRecord
	extend Mobility
  translates :slug, :name, :short_description, :description

	extend FriendlyId
  friendly_id :name, use: :mobility

	has_one_attached :image, dependent: :purge
	has_many_attached :images, dependent: :purge
  belongs_to :sport

  validates_presence_of :name, :short_description, :description
	validates_uniqueness_of :name

	def should_generate_new_friendly_id?
		self.name_changed?
	end

  def valid_date
    "#{self.start_date.strftime('%d/%m/%Y')} - #{self.end_date.strftime('%d/%m/%Y')}"
  end
end
