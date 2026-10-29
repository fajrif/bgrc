class Treatment < ApplicationRecord
	extend Mobility
  translates :name, :short_description

	belongs_to :facility

	has_one_attached :image, dependent: :purge

	validates_presence_of :name, :short_description

	# Same labels as a group class, so a section's class tabs read the same everywhere.
	validates :category, inclusion: { in: GroupClass::CATEGORIES.values }, allow_blank: true

	def category_label
		GroupClass::CATEGORIES.key(category)
	end

	scope :ordered, -> { order(position: :asc, id: :asc) }
end
