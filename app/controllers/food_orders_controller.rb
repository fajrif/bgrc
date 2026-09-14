class FoodOrdersController < ApplicationController
  include PaymentReconciliation
  before_action :set_food_order, only: [:show, :destroy]
  before_action :verify_access!, only: [:show, :destroy]

  # Orders are placed by Api::FoodOrdersController from the Vue Grab & Go menu
  # (restaurants#show); this controller serves the order's own page.

  def show
    # A guest who signs in on the payment step keeps the order they just placed.
    if user_signed_in? && @food_order.guest?
      @food_order.update_columns(user_id: current_user.id, updated_at: Time.current)
      forget_guest_order!(@food_order)
    end

    store_location_for(:user, request.fullpath)

    # A gateway redirect can beat its own webhook back here.
    settle_pending_payment!(@food_order)
  end

  def destroy
    @food_order.cancel!
    forget_guest_order!(@food_order)
    redirect_to back_to_menu_path, alert: "Order cancelled."
  end

  private

  def set_food_order
    @food_order = FoodOrder.find_by_order_id(params[:id])
  end

  def verify_access!
    return redirect_to(back_to_menu_path, alert: "Order not found.") if @food_order.nil?
    return if user_signed_in? && @food_order.user == current_user
    return if user_signed_in? && @food_order.guest?
    return if session_owns?(@food_order)
    redirect_to back_to_menu_path, alert: "You don't have access to this order."
  end

  def back_to_menu_path
    restaurant = Restaurant.friendly.find(RestaurantsController::GRAB_AND_GO_SLUG)
    dining_restaurant_path(restaurant)
  rescue ActiveRecord::RecordNotFound
    dining_path
  end
end
