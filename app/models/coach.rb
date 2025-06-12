class Coach < ApplicationRecord

	default_scope { order(id: :asc) }

	has_one_attached :photo, dependent: :purge
	has_many :bookings

	validates_presence_of :name, :email, :phone
	validates_uniqueness_of :email

	def gender_label
		self.gender == 0 ? "Female" : "Male"
	end

end
