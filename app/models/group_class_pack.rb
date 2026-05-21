class GroupClassPack < ApplicationRecord
  belongs_to :group_class

  validates :sessions_count, :price, presence: true
  validates :sessions_count, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(position: :asc, sessions_count: :asc) }

  def validity_months_effective
    validity_months || group_class.credit_validity_months || configatron.credit_validity_months || 2
  end

  def validity_label
    m = validity_months_effective
    "#{m} #{m == 1 ? 'month' : 'months'}"
  end

  def display_label
    label.presence || (sessions_count == 1 ? "Single Session" : "Pack of #{sessions_count} Sessions")
  end

  def price_label
    ActionController::Base.helpers.number_to_currency(price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end
end
