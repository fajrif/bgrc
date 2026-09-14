class BookingsController < ApplicationController
  include PaymentReconciliation
  before_action :set_booking, only: [:show, :destroy, :invoice, :pay_with_credit]
  before_action :verify_booking_access!, only: [:show, :destroy, :invoice, :pay_with_credit]

  # Court bookings are created by Api::CourtBookingsController from the Vue booking calendar
  # (search#index), add-ons included; this controller serves the booking's own page.

  def show
    if user_signed_in? && @booking.guest?
      # update_columns: claiming a booking must not reprice it.
      @booking.update_columns(user_id: current_user.id, updated_at: Time.current)
      forget_guest_order!(@booking)
    end

    # Store location for Devise redirect after login
    store_location_for(:user, request.fullpath)

    # A gateway redirect can beat its own webhook back here.
    settle_pending_payment!(@booking)

    # This page is the *pre-payment* page: countdown and Pay button. Once the
    # booking is paid none of that applies, so send the owner to their account
    # list with the e-ticket modal open. Guests never reach this branch because
    # paying requires signing in, which claims the booking above.
    if user_signed_in? && @booking.user_id == current_user.id && @booking.status == Booking::PAID
      flash.keep # settle_pending_payment! uses flash.now, which a redirect would drop
      return redirect_to users_bookings_path(booking: @booking.order_id)
    end

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

  def destroy
    @booking.cancel!
    forget_guest_order!(@booking)
    redirect_to search_path, alert: "Booking cancelled."
  end

  # The per-booking invoice was retired in favour of one Receipt per Purchase,
  # which covers golf, food orders and class credits too. The route stays so any
  # bookmarked link still resolves.
  def invoice
    purchase = @booking.purchase
    if user_signed_in? && purchase&.paid? && purchase.user_id == current_user.id
      redirect_to users_payment_path(id: purchase.id)
    else
      redirect_to booking_path(@booking.order_id)
    end
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

  def verify_booking_access!
    return redirect_to(search_path, alert: "Booking not found.") if @booking.nil?
    return if user_signed_in? && @booking.user == current_user
    return if user_signed_in? && @booking.guest?
    return if session_owns?(@booking)
    redirect_to search_path, alert: "You don't have access to this booking."
  end
end
