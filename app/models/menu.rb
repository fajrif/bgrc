class Menu < ApplicationRecord
	extend Mobility
	translates :name, :short_description

	belongs_to :restaurant
	belongs_to :menu_category, optional: true

	has_one_attached :image, dependent: :purge

	validates_presence_of :name, :short_description
	# Ordering fields are only required once the item is actually put on sale, so a
	# plain menu-highlight card on a restaurant page still saves with nothing set.
	validates_presence_of :menu_category, :price, if: :orderable?
	validates :price, numericality: { greater_than: 0 }, if: :orderable?
	validates :stock_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
	validate :discount_below_price

	# On sale at all, versus on sale and actually in stock right now.
	scope :orderable, -> { where(orderable: true).where("menus.price > 0") }
	scope :available, -> { orderable.where(in_stock: true).where("stock_count IS NULL OR stock_count > 0") }

	# Matches Facility#card_image / Amenity#card_image so shared/_category_card
	# can render any of the three without a conditional.
	def card_image
		image
	end

	# What a guest is charged today — the discount when there is one.
	def effective_price
		discounted? ? discount_price : price
	end

	def discounted?
		discount_price.present? && discount_price < price
	end

	def available?
		in_stock? && (stock_count.nil? || stock_count > 0)
	end

	def price_label
		currency(effective_price)
	end

	def original_price_label
		currency(price)
	end

	def stock_label
		return "Out of stock" unless available?
		stock_count.nil? ? "In stock" : "#{stock_count} left"
	end

	# Called once an order is paid. Unlimited items are left alone; a counted item
	# that hits zero takes itself off the menu.
	def decrement_stock!(quantity)
		return if stock_count.nil?

		remaining = [stock_count - quantity.to_i, 0].max
		update_columns(stock_count: remaining, in_stock: remaining.positive?)
	end

	private

	def currency(amount)
		ActionController::Base.helpers.number_to_currency(amount, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end

	def discount_below_price
		return if discount_price.blank? || price.blank?
		errors.add(:discount_price, "must be lower than the normal price") if discount_price >= price
	end
end
