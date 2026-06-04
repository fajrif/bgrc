class GolfItem < ApplicationRecord
  belongs_to :golf_course, optional: true
  has_many :golf_add_ons, dependent: :destroy

  enum :price_type, { per_person: 0, flat: 1 }
  enum :status, { active: 0, inactive: 1 }

  validates_presence_of :name, :price

  def price_label
    suffix = per_person? ? " / Person" : " / Booking"
    ActionController::Base.helpers.number_to_currency(price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0) + suffix
  end
end
