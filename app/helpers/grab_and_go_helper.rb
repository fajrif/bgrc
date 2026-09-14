module GrabAndGoHelper
	# Props for GrabAndGoApp (app/frontend/components/grab_and_go/GrabAndGoApp.vue). Prices here are only
	# for display; Api::FoodOrdersController re-reads them when the order is placed.
	def grab_and_go_props(menus:, categories:)
		{
			menus: menus.map do |menu|
				{
					id: menu.id,
					name: menu.name,
					categoryName: menu.menu_category&.name,
					categorySlug: menu.menu_category&.slug,
					price: menu.effective_price.to_i,
					originalPrice: (menu.price.to_i if menu.discounted?),
					available: menu.available?,
					stock: menu.stock_count,
					imageUrl: (url_for(menu.image.variant(resize_to_fill: [300, 300])) if menu.image.attached?),
				}
			end,
			categories: categories.map { |category| { slug: category.slug, name: category.name } },
			# Prefilled for members; blank strings (never nil) for guests.
			customer: { name: current_user&.full_name.to_s.presence || "", phone: current_user&.phone.to_s.presence || "" },
			pickupLocation: FoodOrder::PICKUP_LOCATION,
			paymentWindowMinutes: configatron.payment_window_minutes,
			maxQuantity: Api::FoodOrdersController::MAX_QUANTITY,
			ordersUrl: api_food_orders_path,
		}
	end
end
