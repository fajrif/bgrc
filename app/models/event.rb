class Event < ApplicationRecord
	extend Mobility
  translates :slug, :name, :short_description, :description

	extend FriendlyId
  friendly_id :name, use: :mobility

	scope :featured_events, -> { where("featured = 1") }

	has_one_attached :image, dependent: :purge
	has_many_attached :images, dependent: :purge
  belongs_to :sport
  has_many :event_rsvps, dependent: :destroy

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

  def slots_remaining
    return nil if capacity.to_i == 0
    capacity - event_rsvps.count
  end

  def full?
    capacity.to_i > 0 && slots_remaining <= 0
  end
end
