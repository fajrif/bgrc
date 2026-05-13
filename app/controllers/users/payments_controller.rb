class Users::PaymentsController < Users::BaseController

  def index
    @purchases = current_user.purchases.order(created_at: :desc)
  end

  def show
  end

end

