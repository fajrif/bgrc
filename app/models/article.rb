class Article < ApplicationRecord
	extend Mobility
  translates :slug, :title, :short_description, :meta_title, :meta_description

	extend FriendlyId
  friendly_id :title, use: :slugged

	include PublishedExtension

	translates :content, backend: :action_text

	default_scope { order(published_date: :desc) }

	has_one_attached :image, dependent: :purge
	has_one_attached :file, dependent: :purge
	has_one :action_text_rich_text, class_name: 'ActionText::RichText', as: :record
	belongs_to :category

	# => File
	validates :file, content_type: ['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/msword'],
										size: { less_than: 50.megabytes, message: 'File maximum 50MB' }

	validates :image, content_type: ['image/gif', 'image/png', 'image/jpg', 'image/jpeg'],
										size: { less_than: 50.megabytes, message: 'Image maximum 50MB' }
	validates_presence_of :title
	validates_uniqueness_of :title

	def should_generate_new_friendly_id?
		self.title_changed?
	end

	def self.most_recent_articles(id, limit)
		where("id <> ?", id).limit(limit)
	end

end
