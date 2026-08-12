class Admins::FoodOrdersController < Admins::BaseController
	before_action :set_food_order, except: [:index]

  def index
		FoodOrder.expire_stale_orders!

		criteria = FoodOrder.includes(:user, :purchase, food_order_items: :menu)
		criteria = criteria.where(status: params[:status]) if params[:status].present?
		criteria = criteria.where(fulfillment_status: params[:fulfillment_status]) if params[:fulfillment_status].present?
		if params[:search].present?
			term = "%#{params[:search]}%"
			criteria = criteria.where("order_id ILIKE :term OR customer_name ILIKE :term OR customer_phone ILIKE :term", term: term)
		end

    @food_orders = criteria.page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @food_orders }
      format.js
    end
  end

  def show
  end

	# Walks the kitchen queue: Pending -> Preparing -> Ready -> Collected.
	def fulfillment
		status = params[:fulfillment_status].to_i
		if FoodOrder::FULFILLMENT_LABELS.key?(status)
			@food_order.update(fulfillment_status: status)
			redirect_to admins_food_order_path(@food_order), :notice => "Order marked as #{@food_order.fulfillment_label.downcase}."
		else
			redirect_to admins_food_order_path(@food_order), :alert => "Unknown fulfillment status."
		end
	end

	def cancel
		if @food_order.paid?
			redirect_to admins_food_order_path(@food_order), :alert => "A paid order has to be refunded, not cancelled."
		else
			@food_order.cancel!
			redirect_to admins_food_order_path(@food_order), :notice => "Order cancelled."
		end
	end

	# Paid at the counter rather than through the gateway. Mirrors the cashier path
	# on bookings and golf reservations: a Purchase row is written so the order
	# still shows up in the payment history with a CASHIER payment type.
	def cashier_payment
		if @food_order.paid?
			redirect_to admins_food_order_path(@food_order), :alert => "This order is already paid." and return
		end
		if @food_order.user.nil?
			redirect_to admins_food_order_path(@food_order), :alert => "A guest order has no account to bill. Ask the guest to sign in first." and return
		end

		begin
			@food_order.create_purchase_record!
			@food_order.paid!
			@food_order.send_email_notification!
			redirect_to admins_food_order_path(@food_order), :notice => "Cashier payment recorded."
		rescue => e
			redirect_to admins_food_order_path(@food_order), :alert => "Unable to record payment: #{e.message}"
		end
	end

  def destroy
    @food_order.destroy
    redirect_to admins_food_orders_url, :notice => "Successfully destroyed order."
  end

  private

  def set_food_order
		@food_order = FoodOrder.find(params[:id])
  end
end
