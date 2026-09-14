module Api
	# Places a Grab & Go order from the Vue menu page (GrabAndGoApp). The basket only says which dishes and
	# how many; names, prices and availability are re-read from the database, never taken from the browser.
	# Stock is taken when the order is paid (FoodOrder#paid!), not here.
	class FoodOrdersController < BaseController
		MAX_QUANTITY = 50
		MAX_NOTES_LENGTH = 500

		def create
			lines = basket_lines
			return render_error("Your order is empty.") if lines.empty?

			food_order = FoodOrder.new(
				user: current_user,
				customer_name: params[:customer_name].to_s.strip,
				customer_phone: params[:customer_phone].to_s.strip,
				notes: params[:notes].to_s.strip.first(MAX_NOTES_LENGTH).presence,
			)

			if (problem = build_items(food_order, lines))
				return render_error(problem)
			end
			unless food_order.save
				return render_error(food_order.errors.full_messages.to_sentence, errors: food_order.errors.to_hash(true))
			end

			track_guest_order!(food_order) unless user_signed_in?
			render json: { order_id: food_order.order_id, redirect_url: food_order_path(id: food_order.order_id) }, status: :created
		end

		private

		# { menu_id => quantity }, keeping only positive whole quantities.
		def basket_lines
			raw = params[:items].respond_to?(:to_unsafe_h) ? params[:items].to_unsafe_h : {}
			raw.each_with_object({}) do |(menu_id, quantity), lines|
				lines[menu_id.to_i] = quantity.to_i if menu_id.to_i.positive? && quantity.to_i.positive?
			end
		end

		# Returns a message for the first line that can't be ordered, or nil once every line is built.
		def build_items(food_order, lines)
			menus = Menu.orderable.where(id: lines.keys).index_by(&:id)

			lines.each do |menu_id, quantity|
				menu = menus[menu_id]
				return "One of the items is no longer on the menu. Please refresh the page." if menu.nil?
				return "#{menu.name} has just sold out." unless menu.available?
				return "Only #{menu.stock_count} left of #{menu.name}." if menu.stock_count.present? && quantity > menu.stock_count
				return "You can order up to #{MAX_QUANTITY} of #{menu.name} online." if quantity > MAX_QUANTITY

				food_order.food_order_items.build(menu: menu, quantity: quantity)
			end

			nil
		end
	end
end
