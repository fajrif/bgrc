class Question < ApplicationRecord
	extend Mobility
  translates :title, :description

  SECTIONS = %w[general booking payment promo packages facilities sports location].freeze
  SECTION_LABELS = { "facilities" => "Our Facilities" }.freeze

  validates_presence_of :title, :description, :section
	validates_uniqueness_of :title

  def self.section_label(key)
    SECTION_LABELS[key] || key.titleize
  end
end
