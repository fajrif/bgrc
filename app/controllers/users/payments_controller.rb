class Users::PaymentsController < Users::BaseController
  def index
    @purchases = current_user.purchases
                             .includes(:productable)
                             .page(params[:page]).per(10)
  end

  # The receipt. Renders standalone for printing, or as a fragment for the modal
  # on the payments table — both go through users/payments/_document.
  def show
    @purchase = current_user.purchases.find(params[:id])

    respond_to do |format|
      format.html
      format.js
    end
  end
end
