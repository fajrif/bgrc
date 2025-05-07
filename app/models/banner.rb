class Banner < ApplicationRecord
	extend Mobility
  translates :title, :description

	include QuilleditorExtension

	default_scope { order(order_no: :asc) }

	has_one_attached :image, dependent: :purge

	validates :image, attached: true, content_type: ['image/gif', 'image/png', 'image/jpg', 'image/jpeg', 'image/webp'],
										size: { less_than: 50.megabytes, message: 'Image maximum 50MB' }
	validates_presence_of :title

	belongs_to :banner_section

	def section_id
		return "banner_#{self.banner_section.name.gsub(' ','_').downcase}"
	end

end
