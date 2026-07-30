class Users::PaymentsController < Users::BaseController

  def index
    @purchases = current_user.purchases.order(created_at: :desc).page(params[:page]).per(10)
  end

  # printable receipt behind the "Download" button on the payments table
  def show
    @purchase = current_user.purchases.find(params[:id])
  end

end
