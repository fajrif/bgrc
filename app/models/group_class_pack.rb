class GroupClassPack < ApplicationRecord
  belongs_to :group_class

  validates :sessions_count, :price, presence: true
  validates :sessions_count, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(position: :asc, sessions_count: :asc) }

  def display_label
    label.presence || (sessions_count == 1 ? "Single Session" : "Pack of #{sessions_count} Sessions")
  end

  def price_label
    ActionController::Base.helpers.number_to_currency(price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end
end
