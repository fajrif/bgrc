class GolfReservationsController < ApplicationController
  include PaymentReconciliation
  before_action :set_golf_reservation, only: [:show, :destroy]
  before_action :verify_access!, only: [:show, :destroy]

  # Tee times are reserved by Api::GolfReservationsController from the Vue golf booking page
  # (golf#index), add-ons included; this controller serves the reservation's own page.

  def show
    if user_signed_in? && @golf_reservation.guest?
      # update_columns: claiming a reservation must not reprice it.
      @golf_reservation.update_columns(user_id: current_user.id, updated_at: Time.current)
      forget_guest_order!(@golf_reservation)
    end

    store_location_for(:user, request.fullpath)

    # A gateway redirect can beat its own webhook back here.
    settle_pending_payment!(@golf_reservation)

    # Same as BookingsController#show: this is the pre-payment page, so once it
    # is paid the owner belongs in My Bookings with the e-ticket modal open.
    if user_signed_in? && @golf_reservation.user_id == current_user.id &&
       @golf_reservation.status == GolfReservation::PAID
      flash.keep # settle_pending_payment! uses flash.now, which a redirect would drop
      return redirect_to users_bookings_path(booking: @golf_reservation.order_id)
    end
  end

  def destroy
    @golf_reservation.cancel!
    forget_guest_order!(@golf_reservation)
    redirect_to golf_path, alert: "Reservation cancelled."
  end

  private

  def set_golf_reservation
    @golf_reservation = GolfReservation.find_by_order_id(params[:id])
  end

  def verify_access!
    return redirect_to(golf_path, alert: "Reservation not found.") if @golf_reservation.nil?
    return if user_signed_in? && @golf_reservation.user == current_user
    return if user_signed_in? && @golf_reservation.guest?
    return if session_owns?(@golf_reservation)
    redirect_to golf_path, alert: "You don't have access to this reservation."
  end
end
