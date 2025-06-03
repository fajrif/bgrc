class Event < ApplicationRecord
	extend Mobility
  translates :slug, :name, :short_description, :description

	extend FriendlyId
  friendly_id :name, use: :mobility

	scope :featured_events, -> { where("featured = 1") }

	has_one_attached :image, dependent: :purge
	has_many_attached :images, dependent: :purge
  belongs_to :sport

  validates_presence_of :name, :short_description, :description, :start_date, :end_date
	validates_uniqueness_of :name

	def should_generate_new_friendly_id?
		self.name_changed?
	end

	def is_featured?
		self.featured == 1
	end

  def valid_date
    "#{self.start_date.strftime('%d/%m/%Y')} - #{self.end_date.strftime('%d/%m/%Y')}"
  end
end
