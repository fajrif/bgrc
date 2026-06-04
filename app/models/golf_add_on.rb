class GolfAddOn < ApplicationRecord
  belongs_to :golf_reservation
  belongs_to :golf_item

  validates_presence_of :price

  after_initialize :init_record, if: :new_record?

  def init_record
    self.price = self.golf_item.price if self.price.zero?
  end

  def total_price
    if golf_item.per_person?
      price * quantity * golf_reservation.players_count
    else
      price * quantity
    end
  end

  def item_with_quantity
    "#{golf_item.name} (#{quantity}x)"
  end

  def price_label
    ActionController::Base.helpers.number_to_currency(price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

  def total_price_label
    ActionController::Base.helpers.number_to_currency(total_price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end
end
