class Users::FoodOrdersController < Users::BaseController

	def index
		FoodOrder.expire_stale_orders!
		@food_orders = current_user.current_food_orders.page(params[:page]).per(10)
	end

	def history
		FoodOrder.expire_stale_orders!
		@food_orders = current_user.food_order_history.page(params[:page]).per(10)
	end
end
