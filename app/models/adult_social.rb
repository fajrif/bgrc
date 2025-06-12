class AdultSocial < ApplicationRecord
	extend Mobility
  translates :title, :short_description, :description

	default_scope { order(start_date: :desc) }

  belongs_to :sport

  validates_presence_of :title, :short_description, :description, :start_date, :price
	validates_uniqueness_of :title

	def is_invitation_only?
		self.invitation_only == 1
	end

	def gender_label
    if self.gender == 1
      "Male"
    elsif self.gender == 2
      "Female"
    else
      "All"
    end
	end

	def price_label
		ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end
end
