class Highlight < ApplicationRecord
	extend Mobility
  translates :slug, :title, :short_description, :meta_title, :meta_description

	extend FriendlyId
  friendly_id :title, use: :mobility

	include PublishedExtension

	translates :content, backend: :action_text

	default_scope { order(position: :asc, published_date: :desc) }

	has_one_attached :image, dependent: :purge
	has_one :action_text_rich_text, class_name: 'ActionText::RichText', as: :record
	belongs_to :category, optional: true

	validates :image, content_type: ['image/gif', 'image/png', 'image/jpg', 'image/jpeg'],
										size: { less_than: 50.megabytes, message: 'Image maximum 50MB' }
	validates_presence_of :title
	validates_uniqueness_of :title

	scope :published, -> { where(status: 1) }

	def should_generate_new_friendly_id?
		self.title_changed?
	end

	def self.most_recent_highlights(id, limit)
		published.where("id <> ?", id).limit(limit)
	end

	# "Weekly | Golf" — the cadence/category line shown on each card.
	def meta_label
		[tags.presence, category&.name].compact.join(" &nbsp;|&nbsp; ")
	end
end
