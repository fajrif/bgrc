class Admins::ClassCreditPurchasesController < Admins::BaseController

  def index
    criteria = ClassCreditPurchase.includes(:user, :group_class)

    if params[:search].present?
      criteria = criteria.where("order_id ILIKE ?", "%#{params[:search]}%")
    end

    case params[:status]
    when "Paid"
      criteria = criteria.where(status: ClassCreditPurchase::PAID)
    when "Pending"
      criteria = criteria.where(status: ClassCreditPurchase::PENDING)
    end

    if params[:prescheduled].present?
      case params[:prescheduled]
      when "Prescheduled"
        criteria = criteria.joins(:group_class).where(group_classes: { is_prescheduled: true })
      when "Non-prescheduled"
        criteria = criteria.joins(:group_class).where(group_classes: { is_prescheduled: [false, nil] })
      end
    end

    @class_credit_purchases = criteria.order(created_at: :desc)
                                      .page(params[:page])
                                      .per(20)
  end

  def show
    @class_credit_purchase = ClassCreditPurchase.find(params[:id])
  end

  def destroy
    @class_credit_purchase = ClassCreditPurchase.find(params[:id])
    @class_credit_purchase.purchase&.destroy!
    @class_credit_purchase.destroy!
    redirect_to admins_class_credit_purchases_path, notice: "Class credit purchase deleted."
  end

end
