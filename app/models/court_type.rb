class CourtType < ApplicationRecord
  has_many :courts
	validates_presence_of :name
end
