class Users::FoodOrdersController < Users::BaseController

	def index
		@food_orders = current_user.current_food_orders.page(params[:page]).per(10)
	end

	def history
		@food_orders = current_user.food_order_history.page(params[:page]).per(10)
	end
end
