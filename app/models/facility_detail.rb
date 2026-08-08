class FacilityDetail < ApplicationRecord
	extend Mobility
  translates :title, :body

	belongs_to :facility

	validates_presence_of :title, :body

	scope :ordered, -> { order(position: :asc, id: :asc) }
end
