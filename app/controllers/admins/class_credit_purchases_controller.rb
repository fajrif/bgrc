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

  def book_on_behalf
    cp     = ClassCreditPurchase.find(params[:id])
    court  = Court.find(params[:court_id])
    coach  = Coach.find_by(id: params[:coach_id])
    date_s = "#{params[:date]} #{params[:time]}"

    unless cp.valid_credit?
      return redirect_to admins_user_path(cp.user), alert: "No valid credits remaining."
    end

    parsed   = DateTime.parse(date_s) rescue nil
    duration = cp.group_class.min_duration

    if parsed.nil?
      return redirect_to admins_user_path(cp.user), alert: "Invalid date/time."
    end

    date_str_fmt = parsed.strftime("%d/%m/%Y %H:%M")
    unless Booking.check_available_dates?(court.id, date_str_fmt, duration)
      return redirect_to admins_user_path(cp.user), alert: "That slot is already booked."
    end

    booking = Booking.new(
      user:                  cp.user,
      court:                 court,
      coach:                 coach,
      group_class:           cp.group_class,
      class_credit_purchase: cp,
      date:                  parsed,
      end_date:              parsed + duration.hours,
      duration:              duration,
      pax:                   cp.pax,
      court_type:            1,
      status:                Booking::PAID,
      price:                 0,
      price_coach:           0,
      total_price:           0
    )

    if booking.save
      redirect_to admins_user_path(cp.user),
                  notice: "Booking created for #{cp.user.full_name} on #{parsed.strftime('%d %b %Y %H:%M')}."
    else
      redirect_to admins_user_path(cp.user), alert: booking.errors.full_messages.join(", ")
    end
  end

end
