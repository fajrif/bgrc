class FacilityBenefit < ApplicationRecord
	extend Mobility
  translates :title, :description

	belongs_to :facility

	has_one_attached :icon, dependent: :purge

	validates_presence_of :title

	scope :ordered, -> { order(position: :asc, id: :asc) }
end
