class Category < ApplicationRecord
	extend Mobility
  translates :name

	default_scope { order(id: :asc) }

	validates_presence_of :name
	validates_uniqueness_of :name

	has_many :articles
	belongs_to :banner_section, optional: true

end
