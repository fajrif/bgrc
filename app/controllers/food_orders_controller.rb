class FoodOrdersController < ApplicationController
  before_action :set_food_order, only: [:show, :destroy, :expire, :invoice]
  before_action :verify_access!, only: [:show, :destroy, :expire, :invoice]

  def create
    FoodOrder.expire_stale_orders!

    lines = parse_items(params[:items])
    if lines.empty?
      redirect_to back_to_menu_path, alert: "Your order is empty." and return
    end

    @food_order = FoodOrder.new(
      user:           current_user,
      customer_name:  params[:customer_name],
      customer_phone: params[:customer_phone],
      notes:          params[:notes]
    )

    error = build_items!(@food_order, lines)
    redirect_to back_to_menu_path, alert: error and return if error

    if @food_order.save
      session[:guest_food_order_ids] ||= []
      session[:guest_food_order_ids] << @food_order.order_id
      redirect_to food_order_path(@food_order.order_id),
                  notice: "Order placed. Please complete payment within 10 minutes."
    else
      redirect_to back_to_menu_path, alert: @food_order.errors.full_messages.to_sentence
    end
  end

  def show
    # A guest who signs in on the payment step keeps the order they just placed.
    if user_signed_in? && @food_order.guest?
      @food_order.update(user: current_user)
      session[:guest_food_order_ids]&.delete(@food_order.order_id)
    end

    store_location_for(:user, request.fullpath)
    session[:food_order_return_url] = request.fullpath
  end

  def invoice
  end

  def expire
    @food_order.expire! if @food_order.is_unpaid?
    head :ok
  end

  def destroy
    @food_order.cancel!
    session[:guest_food_order_ids]&.delete(@food_order.order_id)
    redirect_to back_to_menu_path, alert: "Order cancelled."
  end

  private

  def set_food_order
    @food_order = FoodOrder.find_by_order_id(params[:id])
  end

  def session_owns_order?
    session[:guest_food_order_ids].is_a?(Array) && session[:guest_food_order_ids].include?(@food_order&.order_id)
  end

  def verify_access!
    return redirect_to(back_to_menu_path, alert: "Order not found.") if @food_order.nil?
    return if user_signed_in? && @food_order.user == current_user
    return if user_signed_in? && @food_order.guest?
    return if session_owns_order?
    redirect_to back_to_menu_path, alert: "You don't have access to this order."
  end

  # The basket arrives as {"menu_id" => quantity} JSON from the checkout modal.
  def parse_items(raw)
    parsed = JSON.parse(raw.to_s) rescue {}
    return {} unless parsed.is_a?(Hash)

    parsed.each_with_object({}) do |(menu_id, quantity), acc|
      qty = quantity.to_i
      acc[menu_id.to_i] = qty if menu_id.to_i.positive? && qty.positive?
    end
  end

  # Prices and availability are re-read from the database — the request only ever
  # says which menu and how many, never what it costs.
  def build_items!(food_order, lines)
    menus = Menu.orderable.where(id: lines.keys).index_by(&:id)

    lines.each do |menu_id, quantity|
      menu = menus[menu_id]
      return "One of the items is no longer on the menu." if menu.nil?
      return "#{menu.name} has just sold out." unless menu.available?

      if menu.stock_count.present? && quantity > menu.stock_count
        return "Only #{menu.stock_count} left of #{menu.name}."
      end

      food_order.food_order_items.build(menu: menu, quantity: quantity)
    end

    nil
  end

  def back_to_menu_path
    restaurant = Restaurant.friendly.find(RestaurantsController::GRAB_AND_GO_SLUG)
    dining_restaurant_path(restaurant)
  rescue ActiveRecord::RecordNotFound
    dining_path
  end
end
