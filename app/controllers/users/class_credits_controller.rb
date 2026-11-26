class Users::ClassCreditsController < Users::BaseController
  def index
    # Credits still in use come first, then used-up, expired and unpaid orders.
    # Each group keeps the newest-first order.
    purchases = current_user.class_credit_purchases.includes(:group_class).order(created_at: :desc).to_a
    @credit_purchases = purchases.partition(&:active_credit?).flatten
  end

  def destroy
    cp = current_user.class_credit_purchases.find(params[:id])
    if cp.paid?
      redirect_to users_class_credits_path, alert: "Paid orders cannot be cancelled."
    else
      cp.destroy
      redirect_to users_class_credits_path, notice: "Order #{cp.order_id} has been cancelled."
    end
  end
end
