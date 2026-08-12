class FoodOrderItem < ApplicationRecord
  belongs_to :food_order
  # The menu can be renamed, repriced or deleted after the fact, so the name and
  # unit price are copied onto the line at add time and read from here afterwards.
  belongs_to :menu, optional: true

  validates_presence_of :name, :price
  validates :quantity, numericality: { greater_than: 0 }

  after_initialize :init_record, if: :new_record?

  def init_record
    return unless menu

    self.name  = menu.name if name.blank?
    self.price = menu.effective_price if price.blank? || price.zero?
  end

  def total_price
    price * quantity
  end

  def item_with_quantity
    "#{name} (#{quantity}x)"
  end

  def price_label
    currency(price)
  end

  def total_price_label
    currency(total_price)
  end

  private

  def currency(amount)
    ActionController::Base.helpers.number_to_currency(amount, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end
end
