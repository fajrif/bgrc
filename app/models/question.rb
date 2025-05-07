class Question < ApplicationRecord
	extend Mobility
  translates :title, :description

  validates_presence_of :title, :description, :section
	validates_uniqueness_of :title
end
