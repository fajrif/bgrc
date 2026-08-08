class Treatment < ApplicationRecord
	extend Mobility
  translates :name, :short_description

	belongs_to :facility

	has_one_attached :image, dependent: :purge

	validates_presence_of :name, :short_description

	scope :ordered, -> { order(position: :asc, id: :asc) }
end
