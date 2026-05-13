class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :add_on, :add_quantity, :remove_quantity, :destroy, :expire, :invoice, :pay_with_credit]
  before_action :verify_booking_access!, only: [:show, :add_on, :add_quantity, :remove_quantity, :destroy, :expire, :invoice, :pay_with_credit]

  def create
    Booking.expire_stale_bookings!

    @court = Court.find(params[:court_id])
    dates = params[:dates]
    duration = params[:duration]

    if dates.blank? or duration.blank?
      redirect_to search_path, alert: "Please select the timetable below and press the submit button."
    else
      parsed_date = DateTime.strptime(dates, "%d/%m/%Y %H:%M") rescue nil
      if parsed_date && parsed_date > 14.days.from_now
        redirect_to search_path, alert: "Bookings can only be made up to 14 days in advance. Please contact us via WhatsApp for special requests." and return
      end

      if Booking.check_available_dates?(@court.id, dates, duration)
        @booking = Booking.new(
          court: @court,
          user: current_user,
          date: DateTime::strptime(dates, "%d/%m/%Y %H:%M"),
          duration: duration,
          court_type: params[:court_type]
        )
        unless params[:group_class_id].blank?
          @booking.group_class_id = params[:group_class_id]
        end
        unless params[:pax].blank?
          @booking.pax = params[:pax]
        end
        @booking.coach_id = params[:coach_id] if params[:coach_id].present?
        if @booking.save
          # Track guest bookings in session
          session[:guest_booking_order_ids] ||= []
          session[:guest_booking_order_ids] << @booking.order_id
          redirect_to booking_path(@booking.order_id), notice: "Court booking added to your booking schedules!"
        else
          redirect_to search_path, alert: "Oops cannot booking this court! please search again."
        end
      else
        redirect_to search_path, alert: "Oops sorry booking dates not available"
      end
    end
  end

  def show
    # Associate guest booking with signed-in user
    if user_signed_in? && @booking.guest? && session_owns_booking?
      @booking.update(user: current_user)
    end

    # Store location for Devise redirect after login
    store_location_for(:user, request.fullpath)
    session[:booking_return_url] = request.fullpath

    @available_credit = find_valid_credit_for_booking(@booking) if @booking.group_class_id.present? && user_signed_in?
  end

  def pay_with_credit
    return head(:forbidden) unless @booking.is_unpaid?
    return head(:forbidden) unless @booking.group_class_id.present?

    credit = find_valid_credit_for_booking(@booking)
    if credit.nil?
      redirect_to booking_path(@booking.order_id), alert: "No valid session credits available for this class." and return
    end

    @booking.update!(status: Booking::PAID, class_credit_purchase: credit)
    @booking.send_email_notification!
    redirect_to booking_path(@booking.order_id), notice: "Booking confirmed using 1 session credit."
  end

  def expire
    if @booking.is_unpaid?
      @booking.expire!
    end
    head :ok
  end

  def add_on
    if @booking.expired? || @booking.cancelled?
      head :unprocessable_entity
      return
    end

    if @item = Item.find(params[:item_id])
      if params["selected"] == "true"
        @add_on = AddOn.create(booking: @booking, item: @item)
      else
        if @add_on = @booking.add_ons.where(item_id: @item.id).first
          @add_on.destroy
        end
      end
      @booking.save
    end

    respond_to do |format|
      format.js { render :update }
    end
  end

  def add_quantity
    if @booking.expired? || @booking.cancelled?
      head :unprocessable_entity
      return
    end

    if @add_on = @booking.add_ons.find(params[:add_on_id])
      @add_on.quantity += 1
      @add_on.save
      @booking.save
    end

    respond_to do |format|
      format.js { render :update }
    end
  end

  def remove_quantity
    if @booking.expired? || @booking.cancelled?
      head :unprocessable_entity
      return
    end

    if @add_on = @booking.add_ons.find(params[:add_on_id])
      if @add_on.quantity > 1
        @add_on.quantity -= 1
        @add_on.save
        @booking.save
      end
    end

    respond_to do |format|
      format.js { render :update }
    end
  end

  def destroy
    @booking.cancel!
    session[:guest_booking_order_ids]&.delete(@booking.order_id)
    redirect_to search_path, alert: "Booking cancelled."
  end

  def invoice
  end

  private

  def find_valid_credit_for_booking(booking)
    return nil unless user_signed_in?
    current_user.class_credit_purchases
                .where(group_class_id: booking.group_class_id, status: ClassCreditPurchase::PAID)
                .select(&:valid_credit?)
                .first
  end

  def set_booking
    @booking = Booking.find_by_order_id(params[:id])
  end

  def session_owns_booking?
    session[:guest_booking_order_ids].is_a?(Array) && session[:guest_booking_order_ids].include?(@booking.order_id)
  end

  def verify_booking_access!
    return if @booking.nil?
    return if user_signed_in? && @booking.user == current_user
    return if session_owns_booking?
    redirect_to search_path, alert: "You don't have access to this booking."
  end
end
